from itertools import product
from sage.arith.all import algdep
from util import *

# Theta functions of (25) in Teitelbaum's
# and also the other theta functions that we need to compute the lambda's according to the formulas (23)
# We sum terms until we get the result to the accuracy prec. When deciding the set of indicies over which we sum, we have made several simplifications that probably cause that we sum more terms than strictly needed for that accuracy, but this probably won't be an issue...
def Theta(p1,p2,p3,version = None,prec = None):
    if prec is None:
        prec = 2 * p1.parent().precision_cap()
    imax = (RR(1)/2 + RR(2*prec + RR(1)/2).sqrt()).ceiling() # note the 2!
    a = QQ(1)/QQ(2)
    b = QQ(1)/QQ(2)
    c = 0
    # print 'Entering Theta %s %s %s'%(a,b,c)
    # Define the different conditions and term forms
    if version is None:
        condition = lambda i,j: b*(i**2-ZZ(i).abs()) + a*(j**2-ZZ(j).abs()) + c*((i-j)**2 - ZZ(i-j).abs())
        resdict = {}
        resdict['1p1m'] = resdict['1p2m'] = 0
        resdict['2p2m'] = resdict['1m2p'] = 0
        resdict['3p3m'] = resdict['2m3p'] = 0
        resdict['2p3m'] = resdict['3m1p'] = resdict['3p1m'] = 0
    elif version == '1p1m':
        condition = lambda i,j: b*i**2 + a*j**2 + c*(i-j)**2
        term = lambda i,j: (-1)**j
    elif version == '1p2m':
        condition = lambda i,j:  b*(i**2-i) + a*(j**2-j) + c*(i-j)**2
        term = lambda i,j: p2**(-i)*p1**(-j)
    elif version == '2p2m':
        condition = lambda i,j: b*i**2 + a*j**2 + c*(i-j)**2
        term = lambda i,j: (-1)**i
    elif version == '1m2p':
        condition = lambda i,j: b*(i**2-i) + a*(j**2-j) + c*(i-j)**2
        term = lambda i,j: p2**(-i)*p1**(-j)*(-1)**(i+j)
    elif version == '3p3m':
        condition = lambda i,j: b*i**2 + a*j**2 + c*(i-j)**2
        term = lambda i,j: (-1)**(i+j)
    elif version == '2m3p':
        condition = lambda i,j: b*(i**2+i) + a*j**2 + c*((i-j)**2+(i-j))
        term = lambda i,j: p2**(i)*p3**((i-j))*(-1)**j
    elif version == '2p3m':
        condition = lambda i,j: b*(i**2+i) + a*j**2 + c*((i-j)**2+(i-j))
        term = lambda i,j: p2**(i)*p3**((i-j))
    elif version == '3m1p':
        condition = lambda i,j: b*i**2 + a*(j**2+j) + c*((i-j)**2+(j-i))
        term = lambda i,j: p1**(j)*p3**((j-i))*(-1)**i
    elif version == '3p1m':
        condition = lambda i,j:  b*i**2 + a*(j**2+j) + c*((i-j)**2+(j-i))
        term = lambda i,j: p1**(j)*p3**((j-i))
    else:
        raise ValueError("Wrong version? version = %s"%version)
    res = 0
    assert imax > 0
    for i in xrange(-imax,imax + 1):
        jmax = RR(2*prec - .25 - i**2 + RR(i).abs())
        if jmax < 0:
            continue
        jmax = (jmax.sqrt()+.5).ceiling()
        for j in xrange(-jmax,jmax + 1):
            newterm = p2**(i**2) * p1**(j**2) * p3**((i-j)**2)
            if version is None:
                p2l_inv_p1l_inv_term = p2**(i**2 -i) * p1**(j**2-j) * p3**((i-j)**2)
                p2lp3l_term = p2**(i**2+i) * p1**(j**2) * p3**((i-j)**2 + (i-j))
                p1lp3l_inv_term = p2**(i**2) * p1**(j**2 + j) * p3**((i-j)**2- (i-j))

                resdict['1p1m'] += newterm * (-1)**j
                resdict['1p2m'] += p2l_inv_p1l_inv_term
                resdict['2p2m'] += newterm * (-1)**i
                resdict['1m2p'] += p2l_inv_p1l_inv_term * (-1)**(i+j)
                resdict['3p3m'] += newterm * (-1)**(i+j)
                resdict['2m3p'] += p2lp3l_term * (-1)**j
                resdict['2p3m'] += p2lp3l_term
                resdict['3m1p'] += p1lp3l_inv_term * (-1)**i
                resdict['3p1m'] += p1lp3l_inv_term
            else:
                res += newterm * term(i,j)
    if version is None:
        return resdict
    else:
        return res

def compare_thetas(th1,th2):
    minval = None
    for ky in th1.iterkeys():
        difference = th1[ky] - th2[ky]
        val = min([QQ(i+j)/2 for i,j,k in difference.exponents()]+[Infinity])
        print ky,": ", val
        if minval is None or val < minval:
            minval = val
    return minval

def lambdavec(p1, p2, p3, prec = None, theta = None, prec_pseries = None):
    if theta is None:
        assert prec is not None
        th = Theta(p1,p2,p3,prec = prec)
    else:
        th = theta

    num = th['3p3m'] * th['2m3p']
    den = th['2p2m'] * th['2p3m']
    if prec_pseries is not None:
        try:
            den.parent()._bg_ps_ring().set_default_prec(prec_pseries)
        except AttributeError:
            pass
    l1 = (num/den)**2
    num = th['1p1m'] * th['3m1p']
    den = th['3p3m'] * th['3p1m']
    l2 = (num/den)**2
    num = th['2p2m']
    num,rem = num.quo_rem(1-p3)
    assert rem == 0
    num *= th['1m2p']
    den = th['1p1m']
    den,rem = den.quo_rem(1+p3)
    assert rem == 0
    den *= th['1p2m']
    l3 = num/den
    l3 *= l3
    return matrix(3,1,[l1,l2,l3])

def lambdavec_padic(p1, p2, p3,prec = None):
    th = Theta(p1,p2,p3,prec = prec)
    num = th['3p3m'] * th['2m3p']
    den = th['2p2m'] * th['2p3m']
    l1 = (num/den)**2
    num = th['1p1m'] * th['3m1p']
    den = th['3p3m'] * th['3p1m']
    l2 = (num/den)**2
    num = th['2p2m'] * th['1m2p'] / (1-p3) # Watch
    den = th['1p1m'] * th['1p2m'] / (1+p3)
    l3 = (num/den)**2
    return matrix(3,1,[l1,l2,l3])

def xvec(p1, p2, p3, prec):
    l1,l2,l3 = lambdavec(p1,p2,p3,prec).list()
    x3 = l3 * ((p3-1)/(p3+1))**2
    den = l2
    try:
        den.parent()._bg_ps_ring().set_default_prec(prec)
    except AttributeError:
        pass
    x2 = 1 - 1/den
    den = 1-l1
    try:
        den.parent()._bg_ps_ring().set_default_prec(prec)
    except AttributeError:
        pass
    x1 = 1/den
    return (x1,x2,x3)

def xvec_padic(p1, p2, p3,prec = None):
    l1,l2,l3 = lambdavec_padic(p1,p2,p3,prec).list()
    return (1/(1-l1),1 - 1/l2,l3 * ((p3-1)/(p3+1))**2 )


def ICI_static(x1,x2,x3):
    x12, x22, x32 = x1 * x1, x2 * x2, x3 * x3
    x13, x23, x33 = x1 * x12, x2 * x22, x3 * x32
    x14, x24, x34 = x1 * x13, x2 * x23, x3 * x33
    x15, x25, x35 = x1 * x14, x2 * x24, x3 * x34
    x16, x26, x36 = x1 * x15, x2 * x25, x3 * x35
    x17, x27, x37 = x1 * x16, x2 * x26, x3 * x36
    x18, x28, x38 = x1 * x17, x2 * x27, x3 * x37

    I2 = 6*x12*x22 - 4*x12*x2*x3 - 4*x1*x22*x3 + 6*x12*x32 - 4*x1*x2*x32 + 6*x22*x32 - 4*x12*x2 - 4*x1*x22 - 4*x12*x3 + 12*x1*x2*x3 - 4*x22*x3 - 4*x1*x32 - 4*x2*x32 + 6*x12 - 4*x1*x2 + 6*x22 - 4*x1*x3 - 4*x2*x3 + 6*x32
    I4 = 4*x14*x22*x32 - 4*x13*x23*x32 + 4*x12*x24*x32 - 4*x13*x22*x33 - 4*x12*x23*x33 + 4*x12*x22*x34 - 4*x14*x22*x3 + 4*x13*x23*x3 - 4*x12*x24*x3 - 4*x14*x2*x32 + 4*x13*x22*x32 + 4*x12*x23*x32 - 4*x1*x24*x32 + 4*x13*x2*x33 + 4*x12*x22*x33 + 4*x1*x23*x33 - 4*x12*x2*x34 - 4*x1*x22*x34 + 4*x14*x22 - 4*x13*x23 + 4*x12*x24 - 4*x14*x2*x3 + 4*x13*x22*x3 + 4*x12*x23*x3 - 4*x1*x24*x3 + 4*x14*x32 + 4*x13*x2*x32 - 24*x12*x22*x32 + 4*x1*x23*x32 + 4*x24*x32 - 4*x13*x33 + 4*x12*x2*x33 + 4*x1*x22*x33 - 4*x23*x33 + 4*x12*x34 - 4*x1*x2*x34 + 4*x22*x34 - 4*x13*x22 - 4*x12*x23 + 4*x13*x2*x3 + 4*x12*x22*x3 + 4*x1*x23*x3 - 4*x13*x32 + 4*x12*x2*x32 + 4*x1*x22*x32 - 4*x23*x32 - 4*x12*x33 + 4*x1*x2*x33 - 4*x22*x33 + 4*x12*x22 - 4*x12*x2*x3 - 4*x1*x22*x3 + 4*x12*x32 - 4*x1*x2*x32 + 4*x22*x32
    I6 =8*x16*x24*x32 - 8*x15*x25*x32 + 8*x14*x26*x32 - 8*x16*x23*x33 - 4*x15*x24*x33 - 4*x14*x25*x33 - 8*x13*x26*x33 + 8*x16*x22*x34 - 4*x15*x23*x34 + 24*x14*x24*x34 - 4*x13*x25*x34 + 8*x12*x26*x34 - 8*x15*x22*x35 - 4*x14*x23*x35 - 4*x13*x24*x35 - 8*x12*x25*x35 + 8*x14*x22*x36 - 8*x13*x23*x36 + 8*x12*x24*x36 - 8*x16*x24*x3 + 8*x15*x25*x3 - 8*x14*x26*x3 - 4*x16*x23*x32 + 2*x15*x24*x32 + 2*x14*x25*x32 - 4*x13*x26*x32 - 4*x16*x22*x33 + 40*x15*x23*x33 - 28*x14*x24*x33 + 40*x13*x25*x33 - 4*x12*x26*x33 - 8*x16*x2*x34 + 2*x15*x22*x34 - 28*x14*x23*x34 - 28*x13*x24*x34 + 2*x12*x25*x34 - 8*x1*x26*x34 + 8*x15*x2*x35 + 2*x14*x22*x35 + 40*x13*x23*x35 + 2*x12*x24*x35 + 8*x1*x25*x35 - 8*x14*x2*x36 - 4*x13*x22*x36 - 4*x12*x23*x36 - 8*x1*x24*x36 + 8*x16*x24 - 8*x15*x25 + 8*x14*x26 - 4*x16*x23*x3 + 2*x15*x24*x3 + 2*x14*x25*x3 - 4*x13*x26*x3 + 24*x16*x22*x32 - 28*x15*x23*x32 + 32*x14*x24*x32 - 28*x13*x25*x32 + 24*x12*x26*x32 - 4*x16*x2*x33 - 28*x15*x22*x33 - 4*x14*x23*x33 - 4*x13*x24*x33 - 28*x12*x25*x33 - 4*x1*x26*x33 + 8*x16*x34 + 2*x15*x2*x34 + 32*x14*x22*x34 - 4*x13*x23*x34 + 32*x12*x24*x34 + 2*x1*x25*x34 + 8*x26*x34 - 8*x15*x35 + 2*x14*x2*x35 - 28*x13*x22*x35 - 28*x12*x23*x35 + 2*x1*x24*x35 - 8*x25*x35 + 8*x14*x36 - 4*x13*x2*x36 + 24*x12*x22*x36 - 4*x1*x23*x36 + 8*x24*x36 - 8*x16*x23 - 4*x15*x24 - 4*x14*x25 - 8*x13*x26 - 4*x16*x22*x3 + 40*x15*x23*x3 - 28*x14*x24*x3 + 40*x13*x25*x3 - 4*x12*x26*x3 - 4*x16*x2*x32 - 28*x15*x22*x32 - 4*x14*x23*x32 - 4*x13*x24*x32 - 28*x12*x25*x32 - 4*x1*x26*x32 - 8*x16*x33 + 40*x15*x2*x33 - 4*x14*x22*x33 + 48*x13*x23*x33 - 4*x12*x24*x33 + 40*x1*x25*x33 - 8*x26*x33 - 4*x15*x34 - 28*x14*x2*x34 - 4*x13*x22*x34 - 4*x12*x23*x34 - 28*x1*x24*x34 - 4*x25*x34 - 4*x14*x35 + 40*x13*x2*x35 - 28*x12*x22*x35 + 40*x1*x23*x35 - 4*x24*x35 - 8*x13*x36 - 4*x12*x2*x36 - 4*x1*x22*x36 - 8*x23*x36 + 8*x16*x22 - 4*x15*x23 + 24*x14*x24 - 4*x13*x25 + 8*x12*x26 - 8*x16*x2*x3 + 2*x15*x22*x3 - 28*x14*x23*x3 - 28*x13*x24*x3 + 2*x12*x25*x3 - 8*x1*x26*x3 + 8*x16*x32 + 2*x15*x2*x32 + 32*x14*x22*x32 - 4*x13*x23*x32 + 32*x12*x24*x32 + 2*x1*x25*x32 + 8*x26*x32 - 4*x15*x33 - 28*x14*x2*x33 - 4*x13*x22*x33 - 4*x12*x23*x33 - 28*x1*x24*x33 - 4*x25*x33 + 24*x14*x34 - 28*x13*x2*x34 + 32*x12*x22*x34 - 28*x1*x23*x34 + 24*x24*x34 - 4*x13*x35 + 2*x12*x2*x35 + 2*x1*x22*x35 - 4*x23*x35 + 8*x12*x36 - 8*x1*x2*x36 + 8*x22*x36 - 8*x15*x22 - 4*x14*x23 - 4*x13*x24 - 8*x12*x25 + 8*x15*x2*x3 + 2*x14*x22*x3 + 40*x13*x23*x3 + 2*x12*x24*x3 + 8*x1*x25*x3 - 8*x15*x32 + 2*x14*x2*x32 - 28*x13*x22*x32 - 28*x12*x23*x32 + 2*x1*x24*x32 - 8*x25*x32 - 4*x14*x33 + 40*x13*x2*x33 - 28*x12*x22*x33 + 40*x1*x23*x33 - 4*x24*x33 - 4*x13*x34 + 2*x12*x2*x34 + 2*x1*x22*x34 - 4*x23*x34 - 8*x12*x35 + 8*x1*x2*x35 - 8*x22*x35 + 8*x14*x22 - 8*x13*x23 + 8*x12*x24 - 8*x14*x2*x3 - 4*x13*x22*x3 - 4*x12*x23*x3 - 8*x1*x24*x3 + 8*x14*x32 - 4*x13*x2*x32 + 24*x12*x22*x32 - 4*x1*x23*x32 + 8*x24*x32 - 8*x13*x33 - 4*x12*x2*x33 - 4*x1*x22*x33 - 8*x23*x33 + 8*x12*x34 - 8*x1*x2*x34 + 8*x22*x34
    I10 = x18*x26*x34 - 2*x17*x27*x34 + x16*x28*x34 - 2*x18*x25*x35 + 2*x17*x26*x35 + 2*x16*x27*x35 - 2*x15*x28*x35 + x18*x24*x36 + 2*x17*x25*x36 - 6*x16*x26*x36 + 2*x15*x27*x36 + x14*x28*x36 - 2*x17*x24*x37 + 2*x16*x25*x37 + 2*x15*x26*x37 - 2*x14*x27*x37 + x16*x24*x38 - 2*x15*x25*x38 + x14*x26*x38 - 2*x18*x26*x33 + 4*x17*x27*x33 - 2*x16*x28*x33 + 2*x18*x25*x34 - 2*x17*x26*x34 - 2*x16*x27*x34 + 2*x15*x28*x34 + 2*x18*x24*x35 - 4*x17*x25*x35 + 4*x16*x26*x35 - 4*x15*x27*x35 + 2*x14*x28*x35 - 2*x18*x23*x36 - 2*x17*x24*x36 + 4*x16*x25*x36 + 4*x15*x26*x36 - 2*x14*x27*x36 - 2*x13*x28*x36 + 4*x17*x23*x37 - 2*x16*x24*x37 - 4*x15*x25*x37 - 2*x14*x26*x37 + 4*x13*x27*x37 - 2*x16*x23*x38 + 2*x15*x24*x38 + 2*x14*x25*x38 - 2*x13*x26*x38 + x18*x26*x32 - 2*x17*x27*x32 + x16*x28*x32 + 2*x18*x25*x33 - 2*x17*x26*x33 - 2*x16*x27*x33 + 2*x15*x28*x33 - 6*x18*x24*x34 + 4*x17*x25*x34 + 4*x16*x26*x34 + 4*x15*x27*x34 - 6*x14*x28*x34 + 2*x18*x23*x35 + 4*x17*x24*x35 - 6*x16*x25*x35 - 6*x15*x26*x35 + 4*x14*x27*x35 + 2*x13*x28*x35 + x18*x22*x36 - 2*x17*x23*x36 + 4*x16*x24*x36 - 6*x15*x25*x36 + 4*x14*x26*x36 - 2*x13*x27*x36 + x12*x28*x36 - 2*x17*x22*x37 - 2*x16*x23*x37 + 4*x15*x24*x37 + 4*x14*x25*x37 - 2*x13*x26*x37 - 2*x12*x27*x37 + x16*x22*x38 + 2*x15*x23*x38 - 6*x14*x24*x38 + 2*x13*x25*x38 + x12*x26*x38 - 2*x18*x25*x32 + 2*x17*x26*x32 + 2*x16*x27*x32 - 2*x15*x28*x32 + 2*x18*x24*x33 - 4*x17*x25*x33 + 4*x16*x26*x33 - 4*x15*x27*x33 + 2*x14*x28*x33 + 2*x18*x23*x34 + 4*x17*x24*x34 - 6*x16*x25*x34 - 6*x15*x26*x34 + 4*x14*x27*x34 + 2*x13*x28*x34 - 2*x18*x22*x35 - 4*x17*x23*x35 - 6*x16*x24*x35 + 24*x15*x25*x35 - 6*x14*x26*x35 - 4*x13*x27*x35 - 2*x12*x28*x35 + 2*x17*x22*x36 + 4*x16*x23*x36 - 6*x15*x24*x36 - 6*x14*x25*x36 + 4*x13*x26*x36 + 2*x12*x27*x36 + 2*x16*x22*x37 - 4*x15*x23*x37 + 4*x14*x24*x37 - 4*x13*x25*x37 + 2*x12*x26*x37 - 2*x15*x22*x38 + 2*x14*x23*x38 + 2*x13*x24*x38 - 2*x12*x25*x38 + x18*x24*x32 + 2*x17*x25*x32 - 6*x16*x26*x32 + 2*x15*x27*x32 + x14*x28*x32 - 2*x18*x23*x33 - 2*x17*x24*x33 + 4*x16*x25*x33 + 4*x15*x26*x33 - 2*x14*x27*x33 - 2*x13*x28*x33 + x18*x22*x34 - 2*x17*x23*x34 + 4*x16*x24*x34 - 6*x15*x25*x34 + 4*x14*x26*x34 - 2*x13*x27*x34 + x12*x28*x34 + 2*x17*x22*x35 + 4*x16*x23*x35 - 6*x15*x24*x35 - 6*x14*x25*x35 + 4*x13*x26*x35 + 2*x12*x27*x35 - 6*x16*x22*x36 + 4*x15*x23*x36 + 4*x14*x24*x36 + 4*x13*x25*x36 - 6*x12*x26*x36 + 2*x15*x22*x37 - 2*x14*x23*x37 - 2*x13*x24*x37 + 2*x12*x25*x37 + x14*x22*x38 - 2*x13*x23*x38 + x12*x24*x38 - 2*x17*x24*x32 + 2*x16*x25*x32 + 2*x15*x26*x32 - 2*x14*x27*x32 + 4*x17*x23*x33 - 2*x16*x24*x33 - 4*x15*x25*x33 - 2*x14*x26*x33 + 4*x13*x27*x33 - 2*x17*x22*x34 - 2*x16*x23*x34 + 4*x15*x24*x34 + 4*x14*x25*x34 - 2*x13*x26*x34 - 2*x12*x27*x34 + 2*x16*x22*x35 - 4*x15*x23*x35 + 4*x14*x24*x35 - 4*x13*x25*x35 + 2*x12*x26*x35 + 2*x15*x22*x36 - 2*x14*x23*x36 - 2*x13*x24*x36 + 2*x12*x25*x36 - 2*x14*x22*x37 + 4*x13*x23*x37 - 2*x12*x24*x37 + x16*x24*x32 - 2*x15*x25*x32 + x14*x26*x32 - 2*x16*x23*x33 + 2*x15*x24*x33 + 2*x14*x25*x33 - 2*x13*x26*x33 + x16*x22*x34 + 2*x15*x23*x34 - 6*x14*x24*x34 + 2*x13*x25*x34 + x12*x26*x34 - 2*x15*x22*x35 + 2*x14*x23*x35 + 2*x13*x24*x35 - 2*x12*x25*x35 + x14*x22*x36 - 2*x13*x23*x36 + x12*x24*x36
    return I2, I4, I6, I10

def IgusaClebschFromHalfPeriods(a, b, c, prec = None, padic = True):
    # if a.valuation() < 0 or b.valuation() < 0 or c.valuation() < 0:
    #     a,b,c = 1/a, 1/b, 1/c
    #     if a.valuation() < 0 or b.valuation() < 0 or c.valuation() < 0:
    #         raise RuntimeError
    # if sum(1 for u in [a,b,c] if u.valuation() == 0) > 1:
    #     raise RuntimeError
    # if b.valuation() == 0:
    #     a, b, c = b, c, a
    # if a.valuation() == 0:
    #     a, b, c = b, c, a
    # assert a.valuation() > 0 and b.valuation() > 0 and c.valuation() >= 0
    if padic or prec is None:
        return ICI_static(*xvec_padic(a,b,c,prec))
    else:
        return ICI_static(*xvec(a,b,c,prec))

# computes the p-adic L-invariant
# A = <gamma_1,gamma_1>
# B = <gamma_1,gamma_2>
# D = <gamma_2,gamma_2>
# Tmatrix is the matrix of the T_ell operator with respect to the basis (gamma_1,gamma_2)
# the output is (a,b), where L_p = a + bT
def p_adic_l_invariant(A,B, Tmatrix):
    K = A.parent()
    A, B = K(A), K(B)
    x,y,z,t = Tmatrix.change_ring(K).list()
    alpha,beta = A.ordp(),B.ordp()
    M = Matrix(K,2,2,[alpha,x*alpha+z*beta,beta, y*alpha+t*beta])
    n  = Matrix(K,2,1,[A.log(0),B.log(0)])
    return M.solve_right(n).list()

def p_adic_l_invariant_additive(A,B, alpha, beta, Tmatrix):
    K = A.parent()
    A, B = K(A), K(B)
    x,y,z,t = Tmatrix.change_ring(K).list()
    M = Matrix(K,2,2,[alpha,x*alpha+z*beta,beta, y*alpha+t*beta])
    n  = Matrix(K,2,1,[A, B])
    return M.solve_right(n).list()

def qlogs_from_Lp_and_ords(a,b,Tmatrix,q1ord, q2ord, q3ord):
    K = a.parent()
    ordA = q2ord + q3ord
    ordB = -q3ord
    ordD = q1ord + q3ord
    bord = matrix(K,2,2,[ordA,ordB,ordB,ordD]) * Tmatrix
    M = Matrix(K,3,2,[ordA, bord[0,0], ordB, bord[0,1],ordD,bord[1,1]])
    logA, logB, logD = (M * matrix(K,2,1,[a,b])).list()
    return logB + logD, logA + logB, -logB

def all_possible_qords(Tmatrix,N,initial = None):
    # Find linear equation from matrix
    x, y, z, t = [ZZ(o) for o in Tmatrix.list()]
    r = x+y-z-t
    ans = set([])
    # Note: since we assume that the minimal polynomial is irreducible,
    # we already know that z*y*r != 0

    # Know that q1^z = q2^y q3^r
    for ordq2, ordq3 in product(range(N+1),repeat = 2):
        ordq1 = ZZ(y * ordq2 + r * ordq3)
        if ordq1 % z != 0:
            continue
        ordq1 /= z
        ordtup = [ordq1,ordq2,ordq3]
        if all([o >= 0 for o in ordtup]) and len([o for o in ordtup if o == 0]) <= 1:
            ans = ans.union(ans,set([(ordq1, ordq2, ordq3)]))
    # Know that q2^y = q1^z q3^-r
    for ordq1, ordq3 in product(range(N+1),repeat = 2):
        ordq2 = ZZ(z * ordq1 - r * ordq3)
        if ordq2 % y != 0:
            continue
        ordq2 /= y
        ordtup = [ordq1,ordq2,ordq3]
        if all([o >= 0 for o in ordtup]) and len([o for o in ordtup if o == 0]) <= 1:
            ans = ans.union(ans,set([(ordq1, ordq2, ordq3)]))
    # Know that q3^r = q1^z q2^-y
    for ordq1, ordq2 in product(range(N+1),repeat = 2):
        ordq3 = ZZ(z * ordq1 - y * ordq2)
        if ordq3 % r != 0:
            continue
        ordq3 /= r
        ordtup = [ordq1,ordq2,ordq3]
        if all([o >= 0 for o in ordtup]) and len([o for o in ordtup if o == 0]) <= 1:
            ans = ans.union(ans,set([(ordq1, ordq2, ordq3)]))
    tmp = sorted(list(ans),key = lambda x: x[0]+x[1]+x[2])
    t0 = 0
    if initial is not None:
        try:
            t0 = tmp.index(initial)
        except ValueError:
            t0 = 0
    return tmp[t0:]

# use hensel lemma to lift an approximate root x0 of the polynomial f to a root to the desired precision
def ComputeRootFromApprox(f,x0, prec):
    xn = x0
    while True:
        xnn = xn - f.subs(xn)/f.derivative().subs(xn)
        if (xnn-xn).valuation() > prec:
            break
        xn = xnn
    return xn

def recognize_absolute_invariant(j_invariant,base = QQ,phi = None,threshold = 0.9,prec = None, outfile = None):
    deg = base.degree()
    Kp = j_invariant.parent()
    p = Kp.prime()
    if phi is None:
        phi = lambda t:t
    threshold = threshold * RR(p).log(10)
    j_invariant_val = j_invariant.valuation()
    j_invariant = p**-j_invariant_val * j_invariant
    # if prec is not None:
    #     j_invariant = Qp(p,prec)(j_invariant.lift())
    fx = algdep(j_invariant,deg)
    hfx = height_polynomial(fx)
    trash_height = threshold * j_invariant.precision_relative()
    if hfx < trash_height:
        try:
            fwrite('%s (deg = %s, relprec = %s, threshold = %s)'%(RealField(20)(hfx)/RealField(20)(trash_height), fx.degree(), j_invariant.precision_relative(), threshold),outfile)
            return p**j_invariant_val * fx.change_ring(base).roots()[0][0]
        except IndexError:
            raise ValueError('No roots')
    raise ValueError('Unrecognized')

def recognize_invariants(j1,j2,j3,pval,base = QQ,phi = None):
    deg = base.degree()
    x = QQ['x'].gen()
    Kp = j1.parent()
    j2, j3 = Kp(j2), Kp(j3)
    p = Kp.prime()
    if phi is None:
        phi = lambda t:t
    threshold = .9 * RR(p).log(10)
    for froot,_ in algdep(p**pval * j1,deg).roots(base):
        if froot.global_height() > threshold * j1.precision_relative():
            continue
        # At this point we may have recognized j1
        j1 = p**-pval * froot
        I10 = p**pval * froot.denominator()
        verbose('I10 = %s'%I10)
        I2_5 = froot.denominator() * froot
        try:
            for q,e in I2_5.factor():
                if e % 5 != 0:
                    v = 5 - (e % 5)
                    qv = q**v
                    I2_5 *= qv
                    I10 *= qv
        except ArithmeticError: pass
        verbose('I2_5 = %s, I10 = %s'%(I2_5,I10))
        for I2,_ in (x**5 - I2_5).roots(base):
            verbose('I2 = %s'%I2)
            I4p = phi(I10/I2**3) * j2
            for I4,_ in algdep(I4p,deg).roots(base):
                verbose('I4 = %s'%I4)
                if I4.global_height() > threshold * I4p.precision_relative():
                    continue
                I6p = phi(I10/I2**2) * j3
                for I6,_ in algdep(I6p,deg).roots(base):
                    verbose('I6 = %s'%I6)
                    if I6.global_height() > threshold * I6p.precision_relative():
                        continue
                    return (I2, I4, I6, I10)
    raise ValueError('Unrecognized')

def teichmuller_system(self):
    return [self.teichmuller(self(i).lift_to_precision(self.precision_cap())) for i in self.residue_field() if i != 0]

def take_to_Qp(x, tolerance = None):
    if hasattr(x,'trace'):
        ans = x.trace()/x.parent().degree()
    else:
        ans = x.trace_absolute()/x.parent().absolute_degree()
    if tolerance is None:
        tolerance = 3
    if (x.parent()(ans) - x).ordp() - x.ordp() <= tolerance:
        raise ValueError('Input does not look p-adic')
    return ans

def find_igusa_invariants_from_AB(A, B, T, prec, base=QQ, cheatjs=None, phi=None, minval=3, list_I10=None, Pgen=None, outfile=None, threshold=0.85):
    F = A.parent().base_ring()
    p = F.prime()
    x = QQ['x'].gen()
    from mixed_extension import QuadExt
    F.<r> = Qq(p**2, prec)
    K = QuadExt(F,p)
    deg = base.degree()
    F0 = F.residue_field()
    F0.lift = lambda t:F(t).lift_to_precision(F.precision_cap())
    teichF = teichmuller_system(F)
    x, y, z, t = T.list()
    r = x + y - z - t
    for s1, s2 in product(teichF,repeat = 2):
        A1 = A * s1
        B1 = B * s2
        q2 = K(A1 * B1)
        q3 = K(B1**-1)
        q1z = q2**y * q3**r
        try:
            p2,p3 = our_sqrt(q2,K),our_sqrt(q3,K)
        except (ValueError):
            continue
        p1candidates = [o**(ZZ(2z).sign()) for o in our_nroot(q1z, ZZ(2*z).abs(), return_all = True)]
        for p1 in p1candidates:
            try:
                I2c, I4c, I6c, I10c = IgusaClebschFromHalfPeriods(p1,p2,p3,prec = prec,padic = True)
            except (ValueError,RuntimeError):
                continue
            if list_I10 is None:
                # # Get absolute invariants j1, j2, j3
                j1 = I2c**5 / I10c
                j2 = I2c**3 * I4c / I10c
                j3 = I2c**2 * I6c / I10c
                tol = prec/3
                try:
                    j1, j2, j3 = take_to_Qp(j1, tolerance = tol), take_to_Qp(j2, tol), take_to_Qp(j3, tol)
                except ValueError:
                    continue
                if cheatjs is not None:
                    vals = [(u-v).valuation() - u.valuation() for u,v in zip([j1,j2,j3],cheatjs)]
                    if all([o > minval for o in vals]):
                        return (oq1,oq2,oq3,min(vals))
                else:
                    # return recognize_invariants(j1,j2,j3,oq1+oq2+oq3,base = base,phi = phi)
                    try:
                        return (recognize_absolute_invariant(j1,base = base,phi = phi,threshold = threshold,prec = prec, outfile = outfile), 1, 1, 1)
                    except ValueError:
                        continue
            else:
                j1 = (I2c**5 / I10c)
                try:
                    j1n = take_to_Qp(j1, tolerance = prec/3)
                    j1 = j1n * Pgen**ZZ(I10c.ordp())
                except ValueError:
                    continue
                for I10 in list_I10:
                    try:
                        I2c_list = our_nroot( j1 * I10, 5, return_all = True)
                    except ValueError:
                        continue
                    for I2c in I2c_list:
                        try:
                            return (recognize_absolute_invariant(I2c,base = base,phi = phi,threshold = threshold,prec = prec,  outfile = outfile), 1, 1, 1)
                        except ValueError:
                            continue
    return 'Nope'


def find_igusa_invariants_from_L_inv(Lpmat,ordmat,prec,base = QQ,cheatjs = None,phi = None, minval = 3, list_I10 = None, Pgen = None, outfile = None, threshold = 0.85):
    F = Lpmat.parent().base_ring()
    p = F.prime()
    x = QQ['x'].gen()
    from mixed_extension import QuadExt
    F.<r> = Qq(p**2, prec)
    r = F.gen()
    K = QuadExt(F,p)
    y = K.gen()
    deg = base.degree()
    logmat = ordmat * Lpmat
    oq1, oq2, oq3 = [ ordmat[1,0] + ordmat[1,1], ordmat[0,0] + ordmat[0,1], -ordmat[0,1]]
    try:
        q10 = (logmat[1,0] + logmat[1,1]).exp()
        q20 = (logmat[0,0] + logmat[0,1]).exp()
        q30 = (-logmat[0,1]).exp()
    except ValueError:
        return 'Nope'
    F0 = F.residue_field()
    F0.lift = lambda t:F(t).lift_to_precision(F.precision_cap())
    teichF = teichmuller_system(F)
    for s1, s2, s3 in product(teichF,repeat = 3):
        try:
            q1 = K(s1 * q10 * p**oq1)
            q2 = K(s2 * q20 * p**oq2)
            q3 = K(s3 * q30 * p**oq3)
            p1,p2,p3 = our_sqrt(q1,K),our_sqrt(q2,K),our_sqrt(q3,K)
        except (RuntimeError, ValueError):
            continue
        prec0 = prec
        try:
            I2c, I4c, I6c, I10c = IgusaClebschFromHalfPeriods(p1,p2,p3,prec = prec0,padic = True)
        except (ValueError,RuntimeError):
            continue
        if list_I10 is None:
            # # Get absolute invariants j1, j2, j3
            j1 = I2c**5 / I10c
            j2 = I2c**3 * I4c / I10c
            j3 = I2c**2 * I6c / I10c
            tol = prec/3
            try:
                j1, j2, j3 = take_to_Qp(j1, tolerance = tol), take_to_Qp(j2, tol), take_to_Qp(j3, tol)
            except ValueError:
                continue
            if cheatjs is not None:
                vals = [(u-v).valuation() - u.valuation() for u,v in zip([j1,j2,j3],cheatjs)]
                if all([o > minval for o in vals]):
                    return (oq1,oq2,oq3,min(vals))
            else:
                # return recognize_invariants(j1,j2,j3,oq1+oq2+oq3,base = base,phi = phi)
                try:
                    return (recognize_absolute_invariant(j1,base = base,phi = phi,threshold = threshold,prec = prec, outfile = outfile), 1, 1, 1)
                except ValueError:
                    continue
        else:
            j1 = (I2c**5 / I10c)
            try:
                j1n = take_to_Qp(j1, tolerance = prec/3)
                j1 = j1n * Pgen**ZZ(I10c.ordp())
            except ValueError:
                continue
            for I10 in list_I10:
                try:
                    I2c_list = our_nroot( j1 * I10, 5, return_all = True)
                except ValueError:
                    continue
                for I2c in I2c_list:
                    try:
                        return (recognize_absolute_invariant(I2c,base = base,phi = phi,threshold = threshold,prec = prec,  outfile = outfile), 1, 1, 1)
                    except ValueError:
                        continue
    return 'Nope'

def find_igusa_invariants(a, b, T, embedding, prec = None, outfile = None, list_I10 = None, Pgen = None, N = 6, cheatjs = None, parallelize = True):
    fwrite('Trying to recognize invariants...',outfile)
    Pring = embedding.domain()
    if prec is None:
        prec = a.parent().precision_cap()
    Tlist = []
    fT = T.charpoly()
    fT_trace = -fT.list()[1]
    for x0,y,z in product(range(-N, N+1), range(-N, N+1), range(-N, N+1)):
        t = fT_trace - x0
        if x0*t - y*z == fT.list()[0]:
            M = matrix(ZZ,2,2,[x0,y,z,t])
            assert fT == M.charpoly()
            Tlist.append(M)
    Tlist = sorted(Tlist, key = lambda x: max(x[0,0].abs(), x[0,1].abs(), x[1,0].abs(), x[1,1].abs()))
    for ii, tt in enumerate(Tlist):
        fwrite('Doing matrix %s / %s ( = %s)'%(ii,len(Tlist),tt.list()),outfile)
        Lp = a + b * tt
        inp_vec = [(Lp, ordmat, prec, Pring, cheatjs, embedding, 3, list_I10, Pgen, outfile) for ordmat in all_possible_ordmats(Lp,20)]

        num_inpts = len(inp_vec)
        jj = 0
        if parallelize:
            for inpt, outt in parallel(find_igusa_invariants_from_L_inv)(inp_vec):
                jj += 1
                if outt != 'Nope' and outt != '' and 'indistinguishable' not in outt and 'Error' not in outt:
                    fwrite('(%s/%s) %s %s %s %s'%(jj, num_inpts, str(tt.list()), str(inpt[0][0].list()),str(inpt[0][1].list()),str(outt)), outfile)
                elif outt != 'Nope':
                    fwrite('(%s/%s) (%s)...Out: %s'%(jj, num_inpts, inpt[0][1].list(),str(outt)), outfile)
        else:
            for inpt in inp_vec:
                outt = find_igusa_invariants_from_L_inv(*inpt)
                jj += 1
                if outt != 'Nope' and outt != '' and 'indistinguishable' not in outt and 'Error' not in outt:
                    fwrite('(%s/%s) %s %s %s %s'%(jj, num_inpts, str(tt.list()), str(inpt[0][0].list()),str(inpt[0][1].list()),str(outt)), outfile)
                elif outt != 'Nope':
                    fwrite('(%s/%s) (%s)...Out: %s'%(jj, num_inpts, inpt[0][1].list(),str(outt)), outfile)


def frobenius_polynomial(C):
    q = len(C.base_ring())
    N1, N2 = C.count_points(2)
    ap1 = q + 1 - N1
    ap2 = q*q +1 - N2
    r = (ap1*ap1 - ap2)/2
    x = QQ['x'].gen()
    print 'trace = %s'%ap1
    print 'norm = %s'%(r - 2*q)
    return x**4 - ap1 * x**3 + r * x**2 - ap1*q * x + q*q

def euler_factor_twodim(p,T):
    return euler_factor_twodim_tn(p, T.trace(), T.determinant())

def euler_factor_twodim_tn(q,t,n):
    x = QQ['x'].gen()
    return x**4 - t*x**3 + (2*q+n)*x**2 - q*t*x + q*q

def guess_equation(code,pol,Pgen,Dgen,Npgen, Sinf = None,  sign_ap = None, prec = -1, hecke_data_init = None, working_prec = None, recognize_invariants = True, list_I10 = None, return_all = True, compute_G = True, compute_cohomology = True, abtuple = None, logfile = None, **kwargs):
    from cohomology_arithmetic import ArithCoh, get_overconvergent_class_quaternionic
    from sarithgroup import BigArithGroup
    from homology import lattice_homology_cycle
    from itertools import product,chain,izip,groupby,islice,tee,starmap
    from sage.modules.fg_pid.fgp_module import FGP_Module,FGP_Module_class
    from sage.matrix.constructor import matrix,Matrix,block_diagonal_matrix,block_matrix
    from util import tate_parameter,update_progress,get_C_and_C2,getcoords,recognize_point,fwrite
    import os,datetime
    from sage.misc.persist import db
    from sage.rings.padics.precision_error import PrecisionError
    from util import enumerate_words, discover_equation,get_heegner_params,fwrite,quaternion_algebra_invariants_from_ramification, direct_sum_of_maps
    from integrals import integrate_H1
    from sage.misc.misc import alarm, cancel_alarm
    from sage.rings.integer_ring import ZZ

    import os, datetime, ConfigParser

    config = ConfigParser.ConfigParser()
    config.read('config.ini')
    param_dict = config_section_map(config, 'General')
    param_dict.update(config_section_map(config, 'GuessEquation'))
    param_dict.update(kwargs)
    param = Bunch(**param_dict)

    # Get general parameters
    outfile = param.outfile
    use_ps_dists = param.use_ps_dists
    use_shapiro = param.use_shapiro
    use_sage_db = param.use_sage_db
    magma_seed = param.magma_seed
    parallelize = param.parallelize
    Up_method = param.up_method
    use_magma = param.use_magma
    progress_bar = param.progress_bar
    sign_at_infinity = param.sign_at_infinity

    # Get find_curve specific parameters
    grouptype = param.grouptype
    hecke_bound = param.hecke_bound
    timeout = param.timeout

    if Up_method == "bigmatrix" and use_shapiro == True:
        import warnings
        warnings.warn('Use of "bigmatrix" for Up iteration is incompatible with Shapiro Lemma trick. Using "naive" method for Up.')
        Up_method = 'naive'

    global G, Coh, flist, hecke_data, g0, g1, A, B, a, b, T, xi10, xi20, xi11, xi21, Phif

    if pol is None or pol.degree() == 1:
        F = QQ
        P = Pgen
        Pnrm = Pgen
        Pring = QQ
        D = Dgen
        Np = Npgen
        Sinv_places = []
        if abtuple is None:
            abtuple = QuaternionAlgebra(D).invariants()
        else:
            abtuple = (QQ(abtuple[0]), QQ(abtuple[1]))

        if outfile is None:
            outfile = 'atr_surface_%s_%s_%s_%s_%s.txt'%(code,1,P,D,(P*D*Np))
    else:
        F.<r> = NumberField(pol)
        r = F.gen()
        P = F.ideal(Pgen)
        Pnrm = P.norm()
        Pring = P.ring()

        D = F.ideal(Dgen)
        Np = F.ideal(Npgen)
        if Sinf is None:
            Sinf = [-1 for i in F.real_places()]
        Sinf_places = [v for v,o in zip(F.real_places(prec = Infinity),Sinf) if o == -1]
        if abtuple is None:
            abtuple = quaternion_algebra_invariants_from_ramification(F,D,Sinf_places)
        else:
            abtuple = (F(abtuple[0]), F(abtuple[1]))
        if outfile is None:
            outfile = 'atr_surface_%s_%s_%s_%s_%s.txt'%(code,F.discriminant().abs(),Pnrm,D.norm(),(P*D*Np).norm())
    if os.path.isfile(outfile):
        return 'Skipping because outfile exists'

    if Pnrm > 31:
        return 'Giving up, prime norm is too large (Pnrm = %s)'%Pnrm
    fwrite('Starting computation for candidate %s'%str((code,pol,Pgen,Dgen,Npgen,Sinf)),outfile)

    if compute_G:
        G = BigArithGroup(P,abtuple,Np,base = F, use_shapiro = use_shapiro, seed = magma_seed, outfile = outfile, use_sage_db = use_sage_db, magma = None, timeout = timeout, grouptype = grouptype, logfile = logfile)
    if compute_cohomology:
        Coh = ArithCoh(G)
        fwrite('Computed Cohomology group',outfile)
    if hecke_data_init is not None and return_all:
        fwrite('Warning: setting return_all to False because user passed hecke_data_init value', outfile)
        return_all = False

    if return_all:
        all_twodim_cocycles = Coh.get_twodim_cocycle(sign_at_infinity, hecke_data = hecke_data_init, bound = hecke_bound, return_all = True)
    else:
        try:
            all_twodim_cocycles = [ Coh.get_twodim_cocycle(sign_at_infinity, hecke_data = hecke_data_init, bound = hecke_bound, return_all = False) ]
        except ValueError:
            all_twodim_cocycles = []
    if len(all_twodim_cocycles) == 0:
        fwrite('Group not attached to surface',outfile)
        fwrite('DONE WITH COMPUTATION',outfile)
        return 'DONE'
    fwrite('Obtained cocycles',outfile)
    for flist, hecke_data in all_twodim_cocycles:
        # g0, g1 = G.get_homology_kernel(hecke_data = tuple(hecke_data))
        g0, g1 = G.get_pseudo_orthonormal_homology(flist, hecke_data = hecke_data, outfile = outfile)
        g0_shapiro, g1_shapiro = G.inverse_shapiro(g0), G.inverse_shapiro(g1)
        fwrite('Obtained homology generators',outfile)
        if working_prec is None:
            working_prec = max([2 * prec + 10, 30])
        found = False
        while not found:
            try:
                xi10,xi20 = lattice_homology_cycle(G, g0_shapiro, working_prec)
                xi11,xi21 = lattice_homology_cycle(G, g1_shapiro, working_prec)
                found = True
            except PrecisionError:
                working_prec *= 2
                fwrite('Raising working precision to %s and trying again'%working_prec, outfile)
        fwrite('Defined homology cycles', outfile)
        Phif = get_overconvergent_class_quaternionic(P, flist[0], G, prec, sign_at_infinity,sign_ap,use_ps_dists = use_ps_dists,use_sage_db = use_sage_db,parallelize = parallelize,method = Up_method, progress_bar = progress_bar)
        fwrite('Overconvergent lift completed', outfile)

        from integrals import integrate_H1
        num, numval = integrate_H1(G, xi10, Phif, 1, method = 'moments', prec = working_prec, twist = False, progress_bar = progress_bar, multiplicative = False, return_valuation = True)
        den, denval = integrate_H1(G, xi20, Phif, 1, method = 'moments', prec = working_prec, twist = True, progress_bar = progress_bar, multiplicative = False, return_valuation = True)
        A = num - den
        Aval = numval - denval
        fwrite('Finished computation of A period', outfile)
        # A = A.add_bigoh(prec + A.valuation())
        fwrite('A = %s (%s)'%(A,Aval), outfile)

        num, numval = integrate_H1(G, xi11, Phif, 1, method = 'moments', prec = working_prec, twist = False, progress_bar = progress_bar, multiplicative = False, return_valuation = True)
        den, denval = integrate_H1(G, xi21,Phif, 1, method = 'moments', prec = working_prec, twist = True, progress_bar = progress_bar, multiplicative = False, return_valuation = True)
        B = num - den
        Bval = numval - denval
        fwrite('Finished computation of B period', outfile)
        # B = B.add_bigoh(prec + B.valuation())
        fwrite('B = %s (%s)'%(B,Bval), outfile)

        found = False
        for ell, T0 in hecke_data:
            fwrite('ell = %s'%ell, outfile)
            fwrite('T_ell = %s'%str(T0.list()), outfile)
            if T0.charpoly().is_irreducible():
                found = True
                T = T0
                fwrite('The above is the good T', outfile)
        if not found:
            fwrite('Good T not found...', outfile)
            return('DONE WITH ERROR')

        F = A.parent()
        TF = T.change_ring(F)
        a, b = p_adic_l_invariant_additive(A, B, Aval, Bval, TF)

        a = take_to_Qp(a)
        b = take_to_Qp(b)

        Lp = a + b * T
        fwrite('Lp = %s'%str(Lp.list()), outfile)

        if recognize_invariants:
            find_igusa_invariants(a, b, T, embedding = G._F_to_local, outfile = outfile, list_I10 = list_I10, Pgen = G._F_to_local(Pgen))
    fwrite('DONE WITH COMPUTATION', outfile)
    return('DONE')

def all_possible_ordmats(Lpmat, N):
    ans = []
    for x, y, t in product(range(N+1),range(-N,N+1),range(-N,N+1)):
        if x*t == y*y:
            continue
        M = matrix(ZZ,2,2,[x,y,y,t])
        logmat = M * Lpmat
        if logmat.is_symmetric():
            ans.append(M)
    return sorted(ans, key = lambda x: max([x[0,0].abs(),x[0,1].abs(),x[1,1].abs()]))

def jacobian_matrix(fvec):
    f1, f2, f3 = fvec.list()
    x, y, z = f1.variables()
    return Matrix(3,3,[f1.derivative(x), f1.derivative(y), f1.derivative(z),f2.derivative(x), f2.derivative(y), f2.derivative(z),f3.derivative(x), f3.derivative(y), f3.derivative(z)])

def compute_lvec_and_Mlist(prec):
    R = PowerSeriesRing(QQ,names = 'p', num_gens = 3)
    p1, p2, p3 = R.gens()
    R.set_default_prec(prec)
    R._bg_ps_ring().set_default_prec(prec)
    theta = Theta(p1,p2, p3,prec = prec)
    lvec = lambdavec(p1, p2, p3, theta = theta,prec_pseries = prec)
    Mlist = compute_twisted_jacobian_data(lvec)
    lvec = [o.polynomial() for o in lvec.list()]
    save((lvec,Mlist),'lvec_and_Mlist_%s.sobj'%prec)
    return (lvec,Mlist)

def load_lvec_and_Mlist(prec):
    try:
        lvec, Mlist = load('lvec_and_Mlist_%s.sobj'%prec)
    except:
        lvec, Mlist = compute_lvec_and_Mlist(prec)
    return (lvec, Mlist)

def evaluate_twisted_jacobian_matrix(p1,p2,p3,Mlist):
    retvec = []
    for i in range(6):
        retvec.append(Mlist[i](p1,p2,p3))
    h1 = Mlist[6](p1,p2,p3)
    h2 = Mlist[7](p1,p2,p3)
    h3 = Mlist[8](p1,p2,p3)
    ll = ((1-p3)/(1+p3))**2
    h1 = ll * h1
    h2 = ll * h2
    h3 = -4*(1-p3)/(1+p3)**3 * Mlist[9](p1,p2,p3) + ll * h3
    retvec.extend([h1,h2,h3])
    return Matrix(3,3,retvec)

def compute_twisted_jacobian_data(fvec):
    f1, f2, f3 = fvec.list()
    x, y, z = f1.variables()
    Mlist = [o.polynomial() for o in [f1.derivative(x), f1.derivative(y), f1.derivative(z),f2.derivative(x), f2.derivative(y), f2.derivative(z), f3.derivative(x), f3.derivative(y), f3.derivative(z)]] + [f3.polynomial()]
    return Mlist

def find_initial_approx(L1, L2, L3, lvec):
    # Evaluates a matrix M with entries in Z[[x,y,z]] at points x0,y0,z0
    def ev(x0,y0,z0):
        return [lvec[0](x0,y0,z0), lvec[1](x0,y0,z0), ((1-z0)/(1+z0))**2 * lvec[2](x0,y0,z0)]
    K = L1.parent()
    n_tries = 0
    for V in product(product(range(K.base().prime()), repeat = 3), repeat = 3):
        n_tries += 1
        if n_tries % 100 == 0:
            print 'n_tries = %s'%n_tries
        P = [a+b*K.gen()+c*K.base().gen() for a,b,c in V]
        FP = ev(*P)
        if min([(u-v).valuation() for u,v in zip(FP,[L1,L2,L3])]) > 1/2:
            good_P = P
            print P, [(u-v).valuation() for u,v in zip(FP,[L1,L2,L3])]
    return good_P

# given a triple of lambda's returns the corresponding half periods
def HalfPeriodsInTermsOfLambdas(L1, L2, L3, lvec_and_Mlist = None, HP0 = None, prec = None, max_iters = 20):
    K = L1.parent()
    L0 = Matrix(K, 3, 1, [L1, L2, L3])
    if lvec_and_Mlist is None:
        assert prec is not None
        lvec, Mlist = load_lvec_and_Mlist(prec)
    else:
        lvec, Mlist = lvec_and_Mlist
    # Evaluates a matrix M with entries in Z[[x,y,z]] at points x0,y0,z0
    def ev(x0,y0,z0):
        return [lvec[0](x0,y0,z0), lvec[1](x0,y0,z0), ((1-z0)/(1+z0))**2 * lvec[2](x0,y0,z0)]
    if HP0 is None:
        HP0 = [K(0),K(0),K(0)]
    Pn = Matrix(K,3,1,HP0) # 0th approximation
    n_iters = 0
    while n_iters < 20:
        n_iters += 1
        Jinv = evaluate_twisted_jacobian_matrix(*Pn.list(),Mlist = Mlist).inverse()
        FPn = matrix(3,1, ev(*Pn.list()))
        Pnn = Pn - Jinv * (FPn - L0)
        print '(%s)'%n_iters, [(u-v).valuation() for u,v in zip(Pn.list(), Pnn.list())]
        if all([u == v for u,v in zip(Pn.list(), Pnn.list())]):
            return Pn
        Pn = Pnn
    raise RuntimeError,"Does not converge"
