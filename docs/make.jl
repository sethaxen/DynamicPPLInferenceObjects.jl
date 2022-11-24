using DynamicPPLInferenceObjects
using Documenter

DocMeta.setdocmeta!(DynamicPPLInferenceObjects, :DocTestSetup, :(using DynamicPPLInferenceObjects); recursive=true)

makedocs(;
    modules=[DynamicPPLInferenceObjects],
    authors="Seth Axen <seth@sethaxen.com> and contributors",
    repo="https://github.com/TuringLang/DynamicPPLInferenceObjects.jl/blob/{commit}{path}#{line}",
    sitename="DynamicPPLInferenceObjects.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://TuringLang.github.io/DynamicPPLInferenceObjects.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/TuringLang/DynamicPPLInferenceObjects.jl",
    devbranch="main",
)
