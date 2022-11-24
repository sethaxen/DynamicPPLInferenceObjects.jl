default_group(spl) = :posterior
default_group(::DynamicPPL.SampleFromPrior) = :prior

function AbstractMCMC.bundle_samples(
    ts::Vector,
    model::AbstractMCMC.AbstractModel,
    spl::AbstractMCMC.AbstractSampler,
    state,
    chain_type::Type{InferenceObjects.InferenceData};
    group=default_group(spl),
    save_state=false,
    stats=missing,
    dims=(;),
    coords=(;),
    kwargs...,
)
    sample = map(t -> map(concretize, get_params(t)), ts)

    sample_stats = map(t -> map(concretize, get_sample_stats(t)), ts)
    if all(isempty, sample_stats)
        sample_stats = nothing
    end

    # Set up the info tuple.
    attrs = Dict{String,Any}()
    attrs["model_name"] = Base.nameof(model)
    if save_state
        attrs["model"] = model
        attrs["sampler"] = spl
        attrs["samplerstate"] = state
    end

    # Merge in the timing info, if available
    if !ismissing(stats)
        attrs["sample_start_time"] = Dates.format(
            Dates.unix2datetime(stats.start), Dates.ISODateTimeFormat
        )
        attrs["sample_stop_time"] = Dates.format(
            Dates.unix2datetime(stats.stop), Dates.ISODateTimeFormat
        )
    end

    sample_stats_group = group == :prior ? :sample_stats_prior : :sample_stats

    observed_data = group === :posterior ? DynamicPPL.observations(model) : nothing

    # InferenceData construction.
    idata = InferenceObjects.convert_to_inference_data(
        [sample];
        group=group,
        sample_stats_group => [sample_stats],
        observed_data=observed_data,
        attrs=attrs,
        dims=dims,
        coords=coords,
    )
    # TODO: retrieve model arguments and set as constant data
    # TODO: optionally post-process idata to convert index variables like Symbol("x.b[1, :]") to Symbol("x.b")
    return idata
end

# warning: type piracy!
function AbstractMCMC.chainsstack(c::AbstractVector{<:InferenceObjects.InferenceData})
    nchains = length(c)
    nchains == 1 && return c[1]
    groups = map(keys(first(c))) do k
        if k ∈ (:constant_data, :observed_data, :predictions_constant_data)
            return k => first(c)[k]
        else
            k => AbstractMCMC.chainsstack(map(idata -> idata[k], c))
        end
    end
    return InferenceObjects.InferenceData(; groups...)
end
function AbstractMCMC.chainsstack(c::AbstractVector{<:InferenceObjects.Dataset})
    nchains = length(c)
    nchains == 1 && return c[1]
    # TODO: gather our metadata into vectors instead of replacing
    group = cat(c...; dims=:chain)
    # give each chain a different index
    return LookupArrays.set(group, :chain => Base.OneTo(nchains))
end
