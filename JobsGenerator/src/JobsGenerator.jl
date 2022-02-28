module JobsGenerator

using OrderedCollections
using YAML

const include_comment = "# include: /templates.gitlab-ci.yaml\n\n"

const julia_versions = ["1.0", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1"]

const julia_lts = "1.6"
const julia_stable = "1.7"

build_job(julia_version::String) = OrderedDict{String,Any}(
    "build.julia-$julia_version" => OrderedDict{String,Any}(
        "variables" => OrderedDict{String,Any}(
            "CI_JULIA_VERSION" => julia_version
        ),
        "extends" => [
            Symbol(".julia.setup"),
            Symbol(".julia.build"),
        ]
    )
)

test_job(julia_version::String) = OrderedDict{String,Any}(
    "test.julia-$julia_version" => OrderedDict{String,Any}(
        "variables" => OrderedDict{String,Any}(
            "CI_JULIA_VERSION" => julia_version
        ),
        "extends" => [
            Symbol(".julia.setup"),
            Symbol(".julia.test"),
        ],
        "needs" => [
            OrderedDict{String,Any}(
                "job" => Symbol("build.julia-$julia_version"),
                "optional" => true
            )
        ]
    )
)

function generate_jobs_files()
    generate_build_jobs_files()
    generate_test_jobs_files()
end

function generate_build_jobs_files()
    @info "Writing build jobs files"
    for julia_version in julia_versions
        generate_build_jobs_file(julia_version)
    end
    generate_build_jobs_file(julia_stable; julia_version_name = "stable")
    generate_build_jobs_file(julia_lts; julia_version_name = "lts")
end

function generate_build_jobs_file(julia_version::String; julia_version_name = nothing)
    if julia_version_name === nothing
        julia_version_name = julia_version
    end
    write_job_file("build", julia_version_name, build_job(julia_version))
end

function generate_test_jobs_files()
    @info "Writing test jobs files"
    for julia_version in julia_versions
        generate_test_jobs_file(julia_version)
    end
    generate_test_jobs_file(julia_stable; julia_version_name = "stable")
    generate_test_jobs_file(julia_lts; julia_version_name = "lts")
end

function generate_test_jobs_file(julia_version::String; julia_version_name = nothing)
    if julia_version_name === nothing
        julia_version_name = julia_version
    end
    write_job_file("test", julia_version_name, test_job(julia_version))
end

function write_job_file(jobs_type::String, julia_version::String, job::AbstractDict)
    file_path = jobs_file_path(jobs_type, julia_version)
    @info "Writing $jobs_type file for Julia $julia_version to $file_path"
    open(file_path, "w") do io
        write(io, include_comment)
        YAML.write(io, job)
    end
end

jobs_file_path(jobs_type::String, julia_version::String) = joinpath("jobs", "$jobs_type.julia-$julia_version.gitlab-ci.yaml")

end # module
