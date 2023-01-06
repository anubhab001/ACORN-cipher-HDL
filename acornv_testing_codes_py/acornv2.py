
def  print_hex(x):
    x = x[::-1]
    y = ([0] * (len(x) % 4)) + x
    y = ''.join(map(str, y))
    y = '0b'+y
    y = (hex(int(y, 2))[2:]).replace('L','')
    y = ('0' * ( len(x) / 4 +  int(len(x) % 4 > 0) - len(y) ) ) + y
    return y

def acorn_state_update(rounds, a, b, c, d, e, f, g, m_bit, ca_bit, cb_bit):
        ##########################
        #### REMOVE THIS LINE
        ##########################
        #m_bit = 0; 
        #ca_bit = 0; cb_bit = 0

        ks = (  
            a[12] +  d[0] + c[4] + c[0] + 
            f[5]*b[0] + f[5]*a[23] + f[5]*a[0] +
            b[0]*e[0] + b[0]*d[6] +  b[0]*d[0] + 
            a[23]*e[0] + a[23]*d[6] + a[23]*d[0] + 
            a[0]*e[0] + a[0]*d[6] + a[0]*d[0] +
            f[5]*e[0] + f[5]*d[6] + f[5]*d[0] 
        )&1
        
        ##########################
        #### REMOVE THIS LINE
        ##########################
        #ks = 0

        an = ( b[0] + a[23] + a[0] )&1
        bn = ( c[0] + b[5]  + b[0] )&1
        cn = ( d[0] + c[4]  + c[0] )&1
        dn = ( e[0] + d[6]  + d[0] )&1
        en = ( f[0] + e[3]  + e[0] )&1
        fn = ( g[0] + f[5]  + f[0] )&1
        gn = (m_bit + a[0] + c[0] +  b[0] + 1 + 
            f[14]*a[23] +  a[23]*d[6]  +  d[6]*f[14] +
            f[0]*c[4] + e[3]*c[4] + e[0]*c[4] + 
            f[0]*b[5] + e[3]*b[5] + e[0]*b[5] +ca_bit*e[3] +
            cb_bit*ks)&1

        ##########################
        #### REMOVE THIS LINE
        ##########################
        #gn = (ks)&1
        #gn = (1 ^ f[0])


        global intermediate_steps
        if intermediate_steps:
            print rounds, print_hex(a), print_hex(b), print_hex(c), print_hex(d), print_hex(e), print_hex(f), print_hex(g), m_bit, ca_bit, cb_bit, ks
        
        #if rounds == 67:
        #    print [(i,f[i]) for i in range(len(f))[::-1]]
        #if rounds <= 68:
        #    print rounds, [(i,f[i]) for i in range(len(f))[::-1]], '\n'

        #assert rounds == r - 1
        a[:] = a[1:] + [an]
        b[:] = b[1:] + [bn]
        c[:] = c[1:] + [cn]
        d[:] = d[1:] + [dn]
        e[:] = e[1:] + [en]
        f[:] = f[1:] + [fn]
        g[:] = g[1:] + [gn]
        
        return ks

#===============================================================================
def acorn_core(key, iv, ad, p):
    adlen = len(ad); pclen = len(p)
    #---------------------------------------------------------------------------
    
    #---------------------------------------------------------------------------
    a = [0]*61; b = [0]*46; c = [0]*47; d = [0]*39; e = [0]*37; f = [0]*59; g = [0]*4  
    #---------------------------------------------------------------------------
    ########## Version 1 #########m = key + iv + [1] + [0]*1279  # 128 + 128 + 1 + 1279
    m = key + iv + [key[0] ^ 1] + [key[k % 128] for k in range(1,1535+1)]

    ca = [1]*1792
    cb = [1]*1792

    for i in range(1792): acorn_state_update(i, a, b, c, d, e, f, g, m[i], ca[i], cb[i])
    #---------------------------------------------------------------------------
    adlen = len(ad)
    m = ad + [1] + [0]*255
    ca = [1]*(adlen + 128) + [0]*128
    cb = [1]*(adlen + 256)

    for i in range(adlen + 256): acorn_state_update(1792+i, a, b, c, d, e, f, g, m[i], ca[i], cb[i])
    #---------------------------------------------------------------------------
    m  = p[:]
    ca = [1]*pclen 
    cb = [0]*pclen

    ct = []
    z = []
    for i in range(pclen): 
        ks = acorn_state_update(1792+256+adlen+i, a, b, c, d, e, f, g, m[i], ca[i], cb[i])    
        z.append(ks)
        ct.append((ks + m[i])&1)
        #print 1792+256+adlen+i
    #---------------------------------------------------------------------------
    m  = [1] + [0]*255
    ca = [1]*128 + [0]*256
    cb = [0]*256

    for i in range(256): acorn_state_update(1792+256+adlen+pclen+i, a, b, c, d, e, f, g, m[i], ca[i], cb[i])
    #---------------------------------------------------------------------------
    m  = [0]*768
    ca = [1]*768
    cb = [1]*768

    taglen = 128
    tag = []
    for i in range(768):
        ks = acorn_state_update(1792+256+256+adlen+pclen+i, a, b, c, d, e, f, g, m[i], ca[i], cb[i])


        if i > 768 - taglen - 1 : tag.append(ks)
    return z, ct, tag


#===============================================================================
def repeat(bit, s='',l=128, pre=[], post=[], printing=True):
    if len(bit) > l:
        l = len(bit)
    bit = bit[::-1]
    if len(bit) != 0:
        j = bit*(l/len(bit)); 
        assert all([(i == 0 or i == 1) for i in j]); assert not l % len(j)
        j = pre[::-1] + j + post[::-1]

        if printing:
            print s, pretty_print(j,n=s,t=len(j)/4), len(j)
        return j
    else:
        if printing:
            print s, '_', 0
        return []


def pretty_print(s=[], n='', t=32):
    global hw
    if len(s) == 0:
        return '_'
    if hw:
    ## TO MATCH H/W
        return ('0'*(t-1)+(hex(int(''.join(map(str, s)), 2))[2:].replace('L','')))[-t:]

    else:
        ## TO MATCH WU 
        #print 'n = ', n
        #if n.lower() == 'k' or n.lower() == 'i':# or n.lower() == 't':
        #    t = 32
            #x = ([ hex(int('0b'+((bin(int('0x'+y, 16))[2:][::-1])+"000")[:4], 2))[2:] for y in tuple(('0'*(t-1)+(hex(int(''.join(map(str, s)), 2))[2:].replace('L','')))[-t:]) ])
        x = ([ hex(int('0b'+((bin(int('0x'+y, 16))[2:][::-1])+"000")[:4], 2))[2:] for y in tuple(('0'*(t-1)+(hex(int(''.join(map(str, s)), 2))[2:].replace('L','')))[-t:]) ])
        #else:
        #    x = ([ hex(int('0b'+((bin(int('0x'+y, 16))[2:][::-1])+"000")[:4], 2))[2:] for y in tuple(((hex(int(''.join(map(str, s)), 2))[2:].replace('L','')))[:]) ])
        #print l
        return ''.join(i+j for i,j in zip(x[1::2], x[::2]))


#hw = False; intermediate_steps = False
if __name__ == '__main__':
    print 'Run from testcases'

    """
    key = repeat([0], s='K')
    iv = repeat([0], s='I')
    ad = repeat([], s='A',l=0)
    p = [0,0,0,1][::-1]

    z, ct, tag = acorn_core(key, iv, ad, p)
    print
    print '======================='
    print 'C', pretty_print(ct)
    print 'T', pretty_print(tag)
    """