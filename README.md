# DynamicPPLInferenceObjects

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://sethaxen.github.io/DynamicPPLInferenceObjects.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://sethaxen.github.io/DynamicPPLInferenceObjects.jl/dev/)
[![Build Status](https://github.com/sethaxen/DynamicPPLInferenceObjects.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/sethaxen/DynamicPPLInferenceObjects.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/sethaxen/DynamicPPLInferenceObjects.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/sethaxen/DynamicPPLInferenceObjects.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![ColPrac: Contributor's Guide on Collaborative Practices for Community Packages](https://img.shields.io/badge/ColPrac-Contributor's%20Guide-blueviolet)](https://github.com/SciML/ColPrac)

Experimental support for storing MCMC draws generated using AbstractMCMC and DynamicPPL in the `InferenceObjects.InferenceData`.
This allows `InferenceData` to be a storage container for MCMC draws generated with Turing.

# Example

```julia
julia> using Turing, InferenceObjects, LinearAlgebra, DynamicPPL, DynamicPPLInferenceObjects

julia> function DynamicPPLInferenceObjects.get_params(t::Turing.Inference.HMCTransition)
           return map(v -> length(v[1]) == 1 ? v[1][1] : v[1], t.θ)
       end

julia> function DynamicPPLInferenceObjects.get_sample_stats(t::Turing.Inference.HMCTransition)
           return merge((lp=t.lp,), t.stat)
       end

julia> @model function mymodel(x, max_order, z = x.^(0:max_order)')
           β ~ filldist(Normal(), max_order + 1)
           σ ~ truncated(Normal(); lower=0)
           μ = z * β
           y ~ MvNormal(μ, σ^2 * I)
           return (; μ)
       end;

julia> x = 1:100;

julia> y = sin.(x ./ 10) .+ x .+ randn.();

julia> model = mymodel(x, 2) | (; y);

julia> idata = let
           idata = merge(
               sample(model, Prior(), 1_000; chain_type=InferenceData),
               sample(model, NUTS(), MCMCThreads(), 1_000, 4; chain_type=InferenceData),
           )
           idata = pointwise_loglikelihoods(model, idata)
           idata = predict(decondition(model), idata)
           idata = generated_quantities(model, idata)
       end
InferenceData with groups:
  > posterior
  > posterior_predictive
  > log_likelihood
  > sample_stats
  > prior
  > prior_predictive
  > sample_stats_prior
  > observed_data

julia> idata.posterior
Dataset with dimensions: 
  Dim{:μ_dim_1} Sampled{Int64} Base.OneTo(100) ForwardOrdered Regular Points,
  Dim{:draw} Sampled{Int64} Base.OneTo(1000) ForwardOrdered Regular Points,
  Dim{:chain} Sampled{Int64} Base.OneTo(4) ForwardOrdered Regular Points,
  Dim{:β_dim_1} Sampled{Int64} Base.OneTo(3) ForwardOrdered Regular Points
and 3 layers:
  :μ Float64 dims: Dim{:μ_dim_1}, Dim{:draw}, Dim{:chain} (100×1000×4)
  :β Float64 dims: Dim{:β_dim_1}, Dim{:draw}, Dim{:chain} (3×1000×4)
  :σ Float64 dims: Dim{:draw}, Dim{:chain} (1000×4)

with metadata Dict{String, Any} with 1 entry:
  "created_at" => "2022-11-24T21:35:10.235"

julia> idata.posterior_predictive
Dataset with dimensions: 
  Dim{:y_dim_1} Sampled{Int64} Base.OneTo(100) ForwardOrdered Regular Points,
  Dim{:draw} Sampled{Int64} Base.OneTo(1000) ForwardOrdered Regular Points,
  Dim{:chain} Sampled{Int64} Base.OneTo(4) ForwardOrdered Regular Points
and 1 layer:
  :y Float64 dims: Dim{:y_dim_1}, Dim{:draw}, Dim{:chain} (100×1000×4)

with metadata Dict{String, Any} with 1 entry:
  "created_at" => "2022-11-24T21:35:07.766"
```
