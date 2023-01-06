from acornv2 import repeat, acorn_core, pretty_print
import acornv2
from acornv2_testcases_mine import convert_from_string

def repeat_to_char(l):
	print tuple(map(str, repeat(l, printing=False)))
	print
	print

def convert_to_char(l):
	print tuple(map(str, convert_from_string(l)))
	print
	print


def convert_to_hdl_format(l):
	return str(tuple(map(str, l[::-1])))+';'
#repeat_to_char([1])

def convert_from_output(l):
	t = []
	for a,b,c,d in zip(*[iter(l)]*4):
		t += [d,c,b,a]
	return t
#convert_to_char ("01010101010101010101010101010101")