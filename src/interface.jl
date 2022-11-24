"""
    get_params(transition) -> Union{NamedTuple,Dict{Symbol}}

Get the parameter values for the draw in `transition`.

A default implementation exists only for `DynamicPPL.AbstractVarInfo`. To support any
other transition types, this method must be overloaded.

See also [`get_sample_stats`](@ref).
"""
function get_params end

"""
    get_sample_stats(transition) -> Union{NamedTuple,Dict{Symbol}}

Get the sampling statistics values for the draw in `transition`.

A default implementation exists only for `DynamicPPL.AbstractVarInfo`. For other types, by
default no stats are returned.

    get_sample_stats(transitions, sampler, state) -> Union{NamedTuple,Dict{Symbol}}

Get any sampling statistics values computed for the transitions with the provided sampler and state.

See also [`get_params`](@ref).
"""
function get_sample_stats end
get_sample_stats(::Any) = (;)
get_sample_stats(ts, spl, state) = (;)
