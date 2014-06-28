"""
FLINT fmpz_mat class wrapper

AUTHOR: Marc Masdeu (2014-06)
"""

#*****************************************************************************
#       Copyright (C) 2007 Robert Bradshaw <robertwb@math.washington.edu>
#
#  Distributed under the terms of the GNU General Public License (GPL)
#
#    This code is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#    General Public License for more details.
#
#  The full text of the GPL is available at:
#
#                  http://www.gnu.org/licenses/
#*****************************************************************************

include "sage/ext/stdsage.pxi"
include "fmpz_mat.pxi"

from sage.libs.flint cimport *
from sage.rings.integer_ring import ZZ
from sage.structure.sage_object cimport SageObject
from sage.rings.integer cimport Integer
from sage.matrix.matrix_generic_dense cimport Matrix_generic_dense
from sage.matrix.constructor import Matrix,matrix

cdef vec_dot_vec(Fmpz_mat mtx, vec,R):
    cdef unsigned long p = R.prime()
    cdef unsigned long i
    ans = R(0)
    for i from 0 <= i < mtx.nrows():
        ans += vec[i] * mtx[i,0]
    return ans

cdef class Fmpz_mat(SageObject):
    cdef fmpz_mat_t mat
    #cdef fmpz_t _mod
    cdef unsigned long _nrows
    cdef unsigned long _ncols

    def __cinit__(self):#,unsigned long nrows,unsigned long ncols):
        fmpz_mat_init(self.mat,self._nrows,self._ncols)

    def __dealloc__(self):
        r"""
        """
        fmpz_mat_clear(self.mat)

    def __init__(self,  x, check=True,
                 construct=False):
        r"""
        EXAMPLES::

        """
        cdef long i,j

        self._nrows = x.nrows()
        self._ncols = x.ncols()

        fmpz_mat_init(self.mat,self._nrows,self._ncols)

        for i from 0 <= i < x.nrows():
            for j from 0<= j < x.ncols():
                a = x[i,j]
                if PY_TYPE_CHECK_EXACT(a, int):
                    sig_on()
                    fmpz_set_ui(fmpz_mat_entry(self.mat, i, j),a)
                    sig_off()
                else:
                    if not PY_TYPE_CHECK(a, Integer):
                        a = ZZ(a)
                    sig_on()
                    fmpz_set_mpz(fmpz_mat_entry(self.mat, i, j),(<Integer>a).value)
                    sig_off()

    def nrows(self):
        return self._nrows

    def ncols(self):
        return self._ncols

    def __getitem__(self, key):
        r"""
        Returns entry i,j.

        EXAMPLES::

        """
        cdef long i, j
        key_tuple = <tuple>key
        i = <object>PyTuple_GET_ITEM(key_tuple, 0)
        j = <object>PyTuple_GET_ITEM(key_tuple, 1)
        cdef Integer z = <Integer>PY_NEW(Integer)
        if i < 0 or j < 0 or i > self._nrows or j > self._ncols:
            return z
        else:
            fmpz_get_mpz(z.value,fmpz_mat_entry(self.mat, i, j))
            return z

    def square_inplace(self):
        fmpz_mat_sqr(self.mat , self.mat)

    def __add__(Fmpz_mat self,Fmpz_mat right):
        cdef Fmpz_mat res = <Fmpz_mat>PY_NEW(Fmpz_mat)
        res._nrows = self._nrows
        res._ncols = self._ncols
        sig_on()
        fmpz_mat_init(res.mat,res._nrows,res._ncols)
        fmpz_mat_add(res.mat,self.mat,right.mat)
        sig_off()
        return res

    def __neg__(Fmpz_mat self):
        cdef Fmpz_mat res = <Fmpz_mat>PY_NEW(Fmpz_mat)
        cdef long minus_one = <long>(-1)
        res._nrows = self._nrows
        res._ncols = self._ncols
        sig_on()
        fmpz_mat_init(res.mat,res._nrows,res._ncols)
        fmpz_mat_scalar_mul_si(res.mat,self.mat,minus_one)
        sig_off()
        return res

    def zeromatrix(Fmpz_mat self):
        cdef Fmpz_mat res = <Fmpz_mat>PY_NEW(Fmpz_mat)
        res._nrows = self._nrows
        res._ncols = self._ncols
        sig_on()
        fmpz_mat_init(res.mat,res._nrows,res._ncols)
        fmpz_mat_zero(res.mat)
        sig_off()
        return res

    def identitymatrix(Fmpz_mat self):
        cdef Fmpz_mat res = <Fmpz_mat>PY_NEW(Fmpz_mat)
        res._nrows = self._nrows
        res._ncols = self._ncols
        sig_on()
        fmpz_mat_init(res.mat,res._nrows,res._ncols)
        fmpz_mat_one(res.mat)
        sig_off()
        return res

    
    def __sub__(Fmpz_mat self,Fmpz_mat right):
        cdef Fmpz_mat res = <Fmpz_mat>PY_NEW(Fmpz_mat)
        res._nrows = self._nrows
        res._ncols = self._ncols
        sig_on()
        fmpz_mat_init(res.mat,res._nrows,res._ncols)
        fmpz_mat_sub(res.mat,self.mat,right.mat)
        sig_off()
        return res

    def __mul__(Fmpz_mat self,Fmpz_mat right):
        cdef Fmpz_mat res = <Fmpz_mat>PY_NEW(Fmpz_mat)
        res._nrows = self._nrows
        res._ncols = right._ncols
        sig_on()
        fmpz_mat_init(res.mat,res._nrows,res._ncols)
        fmpz_mat_mul(res.mat,self.mat,right.mat)
        sig_off()
        return res


    def __pow__(Fmpz_mat self,unsigned long n,dummy):
        cdef Fmpz_mat res = <Fmpz_mat>PY_NEW(Fmpz_mat)
        res._nrows = self._nrows
        res._ncols = self._ncols
        sig_on()
        fmpz_mat_init(res.mat,res._nrows,res._ncols)
        fmpz_mat_pow(res.mat,self.mat,n)
        sig_off()
        return res

    def modreduce(Fmpz_mat self,modulus):
        cdef long i,j
        cdef fmpz_t tmp
        cdef fmpz_t modf
        fmpz_init(modf)
        fmpz_set_mpz(modf,(<Integer>modulus).value)
        for i from 0 <= i < self._nrows:
            for j from 0 <= j < self._ncols:
                fmpz_init_set(tmp,fmpz_mat_entry(self.mat, i, j))
                fmpz_fdiv_r(tmp,tmp,modf)
                fmpz_init_set(fmpz_mat_entry(self.mat, i, j),tmp)

    def _pretty_print(self):
        fmpz_mat_print_pretty(self.mat)

    def _repr_(Fmpz_mat self, bint latex=False):
        """
        Return string representation of this matrix.

        EXAMPLES::

        """
        return 'A FLINT Matrix'

    def _sage_(Fmpz_mat self):
        from sage.matrix.constructor import Matrix
        return Matrix(ZZ,self._nrows,self._ncols,[[self[i,j] for j in range(self._ncols)] for i in range(self._nrows)])

    def list(Fmpz_mat self):
        """
        Return a new copy of the list of the underlying
        elements of self.

        EXAMPLES::

        """
        return [self[i,j] for i in range(self._nrows) for j in range(self._ncols)]

