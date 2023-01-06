from acornv2 import repeat, acorn_core, pretty_print
import acornv2
from acornv2_testcases_mine import convert_from_string
from test3 import convert_to_hdl_format, convert_from_output
acornv2.intermediate_steps = False
acornv2.hw = True

def check_from_fille(l, start=0, end=0):
	return ''.join([hex(int('0b'+''.join(map(str, [lines[i+j] ^ p[i+j] for  j in range(4)])), 2))[2:] for i in range(start,end,4)])


#####################

if __name__ == '__main__':
	
	#key = repeat([0], s='K')
	#iv = repeat([0], s='I')
	#ad = repeat([0], s='A',l=128)
	#p = repeat([0], s='P',l=128)
	
	#key = repeat(convert_from_string(s="000102030405060708090a0b0c0d0e0f"), s='K',l=128)
	#iv = repeat(convert_from_string(s="000306090c0f1215181b1e2124272a2d"), s='I',l=128)

	key = repeat(convert_from_string(s="07d102130405161708091a0b0c0d0e0f"), s='K', l=128)
	iv = repeat(convert_from_string(s="fff306090c0f1213181b1e2124272a2d"), s='I', l=128)
	ad = repeat(convert_from_string(s="0a0101010101010f0d0101010101f100"), s='A', l=128)
	p = repeat(convert_from_string(s="c1f101010101020101010d010101e501"), s='P', l=128)
	
	
	print
	print convert_to_hdl_format(key)
	print convert_to_hdl_format(iv)
	print convert_to_hdl_format(ad)
	print convert_to_hdl_format(p)
	
	z, ct, tag = acorn_core(key, iv, ad, p)
	
	
	### Unoptimized
	#path_to_file = 'C:\Users\chipes\Documents\ResearchWorks\ACORNv2\z_values_unopti.txt'
	### 4 round loop unrolled
	path_to_file = 'C:\Users\chipes\Documents\ResearchWorks\Acornv2-4-opti\z_values_4_unrolled.txt'
	### 32 round loop unrolled
	#path_to_file = 'C:\Users\chipes\Documents\ResearchWorks\Acorn-32opti\z_values_32_unrolled.txt'

	lines = open(path_to_file).read().splitlines()

	print
	lx = len(lines[0])
	#print
	#print
	#print 'lines 1', lines
	lines = map(int, tuple(''.join(lines)))
	#print lines
	if lx > 1:
		lines = convert_from_output(lines)
	#print 'lines 2', lines
	
	#print
	#print 'ct =   ', ct
	#print
	assert len(lines) == len(p) + len(tag)

	#print ''.join([hex(int('0b'+''.join(map(str, [lines[i+j] ^ p[i+j] for j in range(4)])), 2))[2:] for i in range(0,len(p),4)])
	#print pretty_print(ct, t=len(p)/4)
	#print
	#print lines
	
	print
		
	print 'C', pretty_print(ct, t=len(p)/4),
	if ''.join([hex(int('0b'+''.join(map(str, [lines[i+j] ^ p[i+j] for j in range(4)])), 2))[2:] for i in range(0,len(p),4)]) == pretty_print(ct, t=len(p)/4):
		print ': validated'
	else:
		raise AssertionError
	
	#print ''.join([hex(int('0b'+''.join(map(str, [lines[i+j] for j in range(4)])), 2))[2:] for i in range(len(p),len(lines),4)]) 
	#print pretty_print(tag, t=len(tag)/4),
	
	print 'T', pretty_print(tag, t=len(tag)/4),
	if ''.join([hex(int('0b'+''.join(map(str, [lines[i+j] for j in range(4)])), 2))[2:] for i in range(len(p),len(lines),4)]) == pretty_print(tag, t=len(tag)/4):
		print ': validated'
	else:
		raise AssertionError
	