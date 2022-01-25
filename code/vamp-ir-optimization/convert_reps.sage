# import fgb_sage

'''
The Question.
Given
    • set of constraints c,     e.g., generators of the output ideal have to be at most degree 2
    • target function ω,        e.g., the total number of variables in the ring
    • ideal I,                  e.g., the ideal generated by the polynomial representing a range check
find set of polynomials f_0, …, f_k such that
    • c holds ∀f_i
    • ω(f_0, …, f_k) is minimized
    • I is the elimination ideal of <f_i> when eliminating vars(<f_i>) - vars(I)

Additional Question:
In general, can we know the minimum that ω can take for a given I, even though finding the corresponding f_i is impossible / infeasible?

Intermediate Questions:
• Is there a better way than Approach 3?
• Is there a better way than Approach 3 for particular input shapes / problems?
• How can we frame Approach 2 (binary decomposition) in a more mathematical / algebraic way?
• For Approach 3, how can we identify if / are there different choices of which reduction to apply that are equivalent (e.g., commutative, or something)?
• Are the ideals that we're dealing with radical?
'''

p = previous_prime(2^15)
field = GF(p)

R = PolynomialRing(field, 'x,a,b,c,d,e,f')
R.inject_variables()

num_variables_in_gb = lambda gb : len(set.union(*[set(p.variables()) for p in gb]))

def print_gb_fan_stats(I):
    gb_fan = I.groebner_fan()
    gbs = gb_fan.reduced_groebner_bases()
    lens_of_gbs = [len(gb) for gb in gbs]
    nums_of_vars = [num_variables_in_gb(gb) for gb in gbs]
    if min(nums_of_vars) != max(nums_of_vars):
        print(f" !!! something is weird with the number of vars! Start your investigation…")
    print(f"#polys in input system: {len(I.basis)}")
    print(f"#vars in input system:  {nums_of_vars[0]}")
    print(f"#GBs in Fan:            {(len(gbs))}")
    print(f"min #polys in GB:       {min(lens_of_gbs)}")
    print(f"max #polys in GB:       {max(lens_of_gbs)}")
    print(f"mean #polys in GB:      {mean(lens_of_gbs).n(digits=3)}")


print(" ===============")
print(" == 3 ≤ x < 6 ==")
print(" ===============")

target_poly = prod([x-i for i in range(3,6)])
print(f"Target polynomial: {target_poly}")

print()
print(" == Gröbner Fan of 'roots of nullifier' ==")

polys0 = [
    (x-3) * (x-4) - a,
    (x-5) * a - b,
    b,
]
I0 = Ideal(polys0)
print_gb_fan_stats(I0)

print()
print(" == Gröbner Fan of 'binary decomposition' ==")

polys1 = [
    # a, b, and c are bits
    (a-0) * (a-1),
    (b-0) * (b-1),
    (c-0) * (c-1),

    # x is the binary decomposition of a, b, c
    2^2*a + 2^1*b + 2^0*c - x,

    # x  a b c  f
    # 0  0 0 0
    # 1  0 0 1
    # 2  0 1 0
    # 3  0 1 1  0
    # 4  1 0 0  0
    # 5  1 0 1  0
    # 6  1 1 0
    # 7  1 1 1

    # DNF
    # (a or not b or not c) and (not a or b)
    # (a + 1-b + 1-c) * (1-a + b),

    # CNF
    # (not a and not b) or (a and b) or (not a and not c)
    ((1-a) * (1-b)) + (a * b) + ((1-a) * (1-c)),
]
I1 = Ideal(polys1)
print_gb_fan_stats(I1)

print()
print(" == Gröbner Fan using reduction by square polynomials ==")

reductor_0 = x^2 - a
reduced_poly_0 = target_poly.reduce([reductor_0])

polys2 = [reduced_poly_0, reductor_0]
I2 = Ideal(polys2)
print_gb_fan_stats(I2)

# == comparison of above fans & gbs

elim_ideal_0 = I0.elimination_ideal(R.gens()[1:]).groebner_basis()
elim_ideal_1 = I1.elimination_ideal(R.gens()[1:]).groebner_basis()
elim_ideal_2 = I2.elimination_ideal(R.gens()[1:]).groebner_basis()

print()
print(f"Elimination Ideal I0: {elim_ideal_0}")
print(f"Elimination Ideal I1: {elim_ideal_1}")
print(f"Elimination Ideal I2: {elim_ideal_2}")
print(f"Elim ideals are same: {elim_ideal_0 == elim_ideal_1 and elim_ideal_1 == elim_ideal_2}")

f = elim_ideal_0[0].univariate_polynomial()

print()
print(f"Roots of that poly:   {sorted([r[0] for r in f.roots()])}")
