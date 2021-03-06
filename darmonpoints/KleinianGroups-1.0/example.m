/*

example.m
An example of use of the package KleinianGroups

example.m is part of KleinianGroups, version 1.0 of September 25, 2012
KleinianGroups is a Magma package computing fundamental domains for arithmetic Kleinian groups.
Copyright (C) 2010-2012  Aurel Page

KleinianGroups is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

KleinianGroups is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with KleinianGroups, in the file COPYING.  If not, see <http://www.gnu.org/licenses/>.

*/

AttachSpec("klngpspec");
SetVerbose("Kleinian", 0);

_<x> := PolynomialRing(Rationals());
F<t> := NumberField(x^3-x+1);
ZF := Integers(F);

D := Factorization(5*ZF)[1][1];
B := QuaternionAlgebra(D, RealPlaces(F));
O := MaximalOrder(B);

//Computation of the norm one group
_, Faces, Edges := NormalizedBasis(O : Maple := true);

G, Generators := Presentation(Faces, Edges, O);

print "presentation :", G;
print "corresponding generators :", Generators, "\n\n";

print "rewriting G.1^(-1) :", Word(Generators[1]^(-1), Faces, G);
print "rewriting G.2*G.7*G.5 :", Word(Generators[2]*Generators[7]*Generators[5], Faces, G);

H := Parent(Faces[1]`Center);
z := (H.1+One(H))/2;

print "reducing (1+i)/2";
zz, _, delta := ReducePoint(z, Faces);

print "reduced point :", zz;
print "delta :", delta, "\n\n";


//precomputation, common to every group (with the same precision) : useful for intensive computations
import "geometry/volumes.m" : ComputeZetas;
print "precomputing coefficients...";
zetas := ComputeZetas(100); 
print "...done.\n\n";


//Computation of the maximal commensurable group
_, Faces, Edges, _, volume := NormalizedBasis(O : GroupType := "Maximal", zetas := zetas);
print "volume of the norm one group :", RealField(6)!Covolume(B);
print "volume of the maximal group :", RealField(6)!volume;

print "minimum radius of a hyperbolic ball centered at 0 containing the fundamental domain :";
print RealField(6)!Radius(Edges);
print "minimum displacement of a loxodromic element in the group :";
print RealField(6)!Systole(Faces, Edges), "\n\n";


//Computations with a Bianchi group
O := BianchiOrder(7);
_, Faces, Edges := NormalizedBasis(O : zetas := zetas);
PG, PGenerators := Presentation(Faces, Edges, O);
print "H_1(PSL2(O_-7), Z) :", AbelianQuotient(PG);
G,Generators := LiftPresentation(PG, PGenerators, O, true);
print "H_1(SL2(O_-7), Z) :", AbelianQuotient(G);

import "bianchi.m" : QuatToMatrix;
print "generators of SL2(O_-7) :", [QuatToMatrix(g) : g in Generators], "\n\n";


//Computation with a non-maximal order
F := NumberField(x^2+7);
B := QuaternionAlgebra<F|-1,-1>;
print "Does the algebra split ?", IsMatrixRing(B);
O := Order([One(B),B.1,B.2,B.3]);
print "Is the order generated by 1,i,j,k maximal ?", IsMaximal(O);
_, Faces, Edges := NormalizedBasis(O : zetas := zetas);
G := Presentation(Faces, Edges, O);
print "Simplified presentation :", Simplify(G), "\n\n";

quit;
