using JuMP, JuCP, ConstraintProgrammingExtensions

using Test

const CP = ConstraintProgrammingExtensions

@testset "JuCP" begin
    @testset "Sets" begin
        @testset "AllDifferent" begin
            m = Model()
            @variable(m, x)
            @variable(m, y)
            @variable(m, z)
            @constraint(m, cref, alldifferent(x, y, z))

            c = JuMP.constraint_object(cref)
            @test c.func == [x, y, z]
            @test c.set == CP.AllDifferent(3)

            m = Model()
            @variable(m, x[1:10])
            @constraint(m, cref, alldifferent(x...))
            # TODO: what about just alldifferent(x)? what's the best syntax?

            c = JuMP.constraint_object(cref)
            @test c.func == x
            @test_broken c.set == CP.AllDifferent(10)
            # TODO: For now, impossible to infer the size of "x..." in JuCP.

            @constraint(m, cref, alldifferent(x[2:end]))

            c = JuMP.constraint_object(cref)
            @test c.func == x
            @test_broken c.set == CP.AllDifferent(9)
            # TODO: For now, impossible to infer the size of "x[^:end]..." in JuCP.

            @constraint(m, cref, alldifferent(x[2:9]))

            c = JuMP.constraint_object(cref)
            @test c.func == x
            @test_broken c.set == CP.AllDifferent(8) # Could do something about it to compute the dimension of the set, but probably not scalable for the other cases.
        end

        @testset "DifferentFrom" begin
            m = Model()
            @variable(m, x)
            @variable(m, y)

            @constraint(m, cref, x != y)

            c = JuMP.constraint_object(cref)
            @test c.func == x - y
            @test c.set == CP.DifferentFrom(0.0)
        end

        @testset "Strictly(LessThan)" begin
            m = Model()
            @variable(m, x)
            @variable(m, y)

            @constraint(m, cref, x < y)

            c = JuMP.constraint_object(cref)
            @test c.func == x - y
            @test c.set == CP.Strictly(MOI.LessThan(0.0))
        end

        @testset "Strictly(GreaterThan)" begin
            m = Model()
            @variable(m, x)
            @variable(m, y)

            @constraint(m, cref, x > y)

            c = JuMP.constraint_object(cref)
            @test c.func == x - y
            @test c.set == CP.Strictly(MOI.GreaterThan(0.0))
        end
    end

    @testset "Bridges" begin
    end
end
