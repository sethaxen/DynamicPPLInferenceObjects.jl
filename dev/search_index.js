var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = DynamicPPLInferenceObjects","category":"page"},{"location":"#DynamicPPLInferenceObjects","page":"Home","title":"DynamicPPLInferenceObjects","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for DynamicPPLInferenceObjects.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [DynamicPPLInferenceObjects]","category":"page"},{"location":"#DynamicPPLInferenceObjects.get_params","page":"Home","title":"DynamicPPLInferenceObjects.get_params","text":"get_params(transition) -> Union{NamedTuple,Dict{Symbol}}\n\nGet the parameter values for the draw in transition.\n\nA default implementation exists only for DynamicPPL.AbstractVarInfo. To support any other transition types, this method must be overloaded.\n\nSee also get_sample_stats.\n\n\n\n\n\n","category":"function"},{"location":"#DynamicPPLInferenceObjects.get_sample_stats","page":"Home","title":"DynamicPPLInferenceObjects.get_sample_stats","text":"get_sample_stats(transition) -> Union{NamedTuple,Dict{Symbol}}\n\nGet the sampling statistics values for the draw in transition.\n\nA default implementation exists only for DynamicPPL.AbstractVarInfo. For other types, by default no stats are returned.\n\nget_sample_stats(transitions, sampler, state) -> Union{NamedTuple,Dict{Symbol}}\n\nGet any sampling statistics values computed for the transitions with the provided sampler and state.\n\nSee also get_params.\n\n\n\n\n\n","category":"function"}]
}