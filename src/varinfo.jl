function DynamicPPL.setval!(
    vi::DynamicPPL.VarInfo, data::InferenceObjects.Dataset, draw_id::Int, chain_id::Int
)
    return DynamicPPL.setval!(vi, data[draw=draw_id, chain=chain_id])
end

function DynamicPPL.setval_and_resample!(
    vi::DynamicPPL.VarInfoOrThreadSafeVarInfo,
    data::InferenceObjects.Dataset,
    draw_id::Int,
    chain_id::Int,
)
    return DynamicPPL.setval_and_resample!(vi, data[draw=draw_id, chain=chain_id])
end

get_params(vi::DynamicPPL.AbstractVarInfo) = DynamicPPL.values_as(vi, NamedTuple)

get_sample_stats(vi::DynamicPPL.AbstractVarInfo) = (lp=DynamicPPL.getlogp(vi),)
