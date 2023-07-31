import numpy as np
import statsmodels.api as sm


def tri_K(t):
    return np.maximum(0, 1-np.abs(t))

def local_linear_reg_backend(r, X, Y, c, kernel, bw, groups=None):
    is_gt = r > c
    
    K_fn = lambda t: kernel((t - r) / bw)
    
    weights = K_fn(X)
    
    subset = (X>c) if (r>c) else (X<c)
    
    Y = Y.copy()
    weights[~subset] = np.nan
    
    if groups is not None:
        subset = subset & ~np.isnan(Y) & ~np.isnan(X)
        cov_type = 'cluster'
        cov_kwds = {'groups': groups[subset]}
        
    else:
        cov_type = 'HC0'
        cov_kwds = None
        
    
        
    res = sm.WLS(
        Y[subset],
        sm.add_constant(X[subset]),
        weights=weights[subset],
        missing='drop'
    ).fit(cov_type=cov_type, cov_kwds=cov_kwds)
    
    return res

def local_linear_reg_pt(r, X, Y, c, kernel, bw):
    return local_linear_reg_backend(r, X, Y, c, kernel, bw).predict([1,r])

def local_linear_reg(X, Y, c, kernel, bw):
    return np.array([
        local_linear_reg_pt(
            r, X, Y, c, kernel, bw
        )
        for r in X
    ])

def sigma(n, bw, f_plus, f_minus):
    return np.sqrt(
        (1/(n*bw)) * (24/5) * (
            (1/f_plus) + (1/f_minus)
        )
    )