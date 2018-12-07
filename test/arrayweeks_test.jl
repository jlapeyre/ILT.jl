
function arrFcomplex(s)
    # Laplace domain
    α = complex(-0.3, 6.0)
    return [1 2;3 4] ./ (s - α)
end

function Fcomplex(s)
    # Laplace domain
    α = complex(-0.3, 6.0)
    return 1 / (s - α)
end

# Test scalar-functionality of arrcoeff, Fcomplex=(s-a)⁻¹
let arr = try InverseLaplace._arrcoeff(Fcomplex,4,1.0,1.0);
    InverseLaplace._arrcoeff(Fcomplex,4,1.0,1.0)
    catch
        InverseLaplace._arrcoeff(Fcomplex,4,1.0,1.0)
    end, scal = InverseLaplace._wcoeff(Fcomplex,4,1.0,1.0)

        @test arr == scal
end

# Test for ordering of array valued coefficients (along first dimension)
let arr = try InverseLaplace._arrcoeff(arrFcomplex,4,1.0,1.0);
    InverseLaplace._arrcoeff(arrFcomplex,4,1.0,1.0)
    catch
        InverseLaplace._arrcoeff(arrFcomplex,4,1.0,1.0)
    end, scal = InverseLaplace._wcoeff(Fcomplex,4,1.0,1.0)
        @test arr[:,1,1] == scal
        @test arr[:,1,2] == 2 .* arr[:,1,1]
        @test isapprox(arr[:,2,1] , 3 .* arr[:,1,1], atol=1E-15)
        @test arr[:,2,2] == 4 .* arr[:,1,1]
end

# Compare _get_coefficients and _laguerre for array functions and scalar functions
let arr = try InverseLaplace._get_array_coefficients(arrFcomplex,4,1.0,1.0,Complex);
    InverseLaplace._get_array_coefficients(arrFcomplex,4,1.0,1.0,Complex)
    catch
        InverseLaplace._get_array_coefficients(arrFcomplex,4,1.0,1.0,Complex)
    end, scal = InverseLaplace._get_coefficients(Fcomplex,4,1.0,1.0,Complex)
        @test arr[:,1,1] == scal
        @test arr[:,1,2] == 2 .* scal
        @test isapprox(arr[:,2,1] , 3 .* scal, atol=1E-15)
        @test arr[:,2,2] == 4 .* scal

        laguerreeval = reshape(mapslices(i -> InverseLaplace._laguerre(i,1.0),arr,dims=(1)),(2,2))
        @test isapprox(laguerreeval, [1 2; 3 4] .* InverseLaplace._laguerre(scal,1.0), atol = 1E-15)
end



# Test the ILT calculation for arrays and compare with the scalar Weeks method
let
    # Weeks parameters
        σ = 1.0
        b = 0.5
        t = 1.0

    # Evaluating ILT for array valued function
    coef = InverseLaplace._get_array_coefficients(arrFcomplex,4,σ,b,Complex)
    lag = reshape(mapslices(i -> InverseLaplace._laguerre(i,2 * b * t),coef,dims=(1)),(2,2))
    inverse = lag .* exp((σ - b) * t)

    # Evaluating ILT for scalar function, then multiplying by an array
    Ft = Weeks(Fcomplex,4,σ,b,datatype=Complex)
    Ft_array_eval = [1 2;3 4]  .* Ft(1.0)

    @test isapprox(Ft_array_eval , inverse, atol=1E-15)
end
