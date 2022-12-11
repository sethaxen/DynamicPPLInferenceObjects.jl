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

julia> y = [28.0, 8.0, -3.0, 7.0, -1.0, 1.0, 18.0, 12.0];

julia> σ = [15.0, 10.0, 16.0, 11.0, 9.0, 11.0, 10.0, 18.0];

julia> schools = ["Choate", "Deerfield", "Phillips Andover", "Phillips Exeter", "Hotchkiss", "Lawrenceville", "St. Paul's", "Mt. Hermon"];

julia> @model function noncentered_eight(σ, J=length(σ))
           μ ~ Normal(0, 5)
           τ ~ truncated(Cauchy(0, 5); lower=0)
           θ_tilde ~ filldist(Normal(), J)
           θ = @. θ_tilde * τ + μ
           y ~ MvNormal(θ, Diagonal(σ.^2))
           return (; θ)
       end;

julia> model = noncentered_eight(σ) | (; y);

julia> idata = let
           dims = (; y=[:school], θ=[:school], θ_tilde=[:school]);
           coords = (; school=schools);
           idata = merge(
               sample(model, Prior(), 1_000; chain_type=InferenceData, dims, coords),
               sample(model, NUTS(), MCMCThreads(), 1_000, 4; chain_type=InferenceData, dims, coords),
           )
           idata = pointwise_loglikelihoods(model, idata)
           idata = predict(decondition(model), idata; dims, coords)
           idata = generated_quantities(model, idata; dims, coords)
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
  Dim{:draw},
  Dim{:chain},
  Dim{:school} Categorical{String} String[Choate, Deerfield, …, St. Paul's, Mt. Hermon] Unordered
and 4 layers:
  :θ       Float64 dims: Dim{:draw}, Dim{:chain}, Dim{:school} (1000×4×8)
  :μ       Float64 dims: Dim{:draw}, Dim{:chain} (1000×4)
  :τ       Float64 dims: Dim{:draw}, Dim{:chain} (1000×4)
  :θ_tilde Float64 dims: Dim{:draw}, Dim{:chain}, Dim{:school} (1000×4×8)

with metadata Dict{String, Any} with 1 entry:
  "created_at" => "2022-12-11T22:45:11.086"

julia> idata.posterior_predictive
Dataset with dimensions: 
  Dim{:draw},
  Dim{:chain},
  Dim{:school} Categorical{String} String[Choate, Deerfield, …, St. Paul's, Mt. Hermon] Unordered
and 1 layer:
  :y Float64 dims: Dim{:draw}, Dim{:chain}, Dim{:school} (1000×4×8)

with metadata Dict{String, Any} with 1 entry:
  "created_at" => "2022-12-11T22:45:10.644"
```
