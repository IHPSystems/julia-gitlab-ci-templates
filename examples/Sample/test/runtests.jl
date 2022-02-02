using Sample: f
using Test

@testset "Sample" begin
    @test f(1) == 2

    @static if Threads.nthreads() > 1
        @assert Threads.nthreads() == Sys.CPU_THREADS
    end
end
