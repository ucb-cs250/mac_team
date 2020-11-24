import argparse
import os 
import sys
import subprocess
import re

import matplotlib.pyplot as plt 
import numpy as np

from math import log
from random import randint


input_width = 8
test_dir = "."
base_dir = ".."
test_result_dir = f"{test_dir}/test_results"


def build_simulator(clean = False):
	try:
	    stdinf = open('/dev/null')
	except Exception as e:
	    try:
	        stdinf = open('nul')
	    except Exception as e:
	        print("Could not open nul or /dev/null. Program will most likely error now.")    
	test_make_output = ""
	test_make_err = "" 
	try:
			if (clean):
				raw_output = subprocess.run([f"rm {test_result_dir}/*", "&&", "make clean", "-C", f"{base_dir}/", "&&", "make","-C", f"{base_dir}/"], check=True, stdin=stdinf, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=240).stdout
			else:
				raw_output = subprocess.run(["make", "-C", f"{base_dir}/"], check=True, stdin=stdinf, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=240).stdout
	except subprocess.CalledProcessError as e:
	    import traceback
	    traceback.print_exc()
	    test_make_output = e.output.decode(sys.getfilesystemencoding())
	    test_make_err = e.stderr.decode(sys.getfilesystemencoding())
	    print('{}'.format(test_make_output))
	    print('An exception has occured!:\n {}'.format(test_make_err))

def run_simulator(n, w, signed, acc):
	data_file = f"{test_result_dir}/results_{w}_{'mac' if acc else 'mul'}_{'signed' if signed else 'unsigned'}.npz"

	if os.path.exists(data_file):
		data = np.load(data_file)
		A = data["arr_0"][0]
		B = data["arr_0"][1]
	else:
		A = np.asarray([])
		B = np.asarray([])

	cfg_string = build_cfg_string(w, signed, acc)
	seed = randint(0, sys.maxsize * 2 + 1)

	try:
	    stdinf = open('/dev/null')
	except Exception as e:
	    try:
	        stdinf = open('nul')
	    except Exception as e:
	        print("Could not open nul or /dev/null. Program will most likely error now.")    

	try:
		test_output = subprocess.run([f"{base_dir}/simulator-mac_test_harness", f"+cfg={cfg_string}", "+verbose=1", f"+num_tests={n}", f"+verilator+seed+{seed}"], 
			check=True, stdin=stdinf, stdout=subprocess.PIPE, stderr=subprocess.PIPE, timeout=600).stdout.decode(sys.getfilesystemencoding())
	except subprocess.CalledProcessError as e:
		test_output = e.output.decode(sys.getfilesystemencoding())
		test_err = e.stderr.decode(sys.getfilesystemencoding())
		print('{}'.format(test_output))
		print('An exception has occured!:\n {}'.format(test_err))
		print("Running simulator failed!")
		return

	passed = len(re.findall(r"PASSED", test_output))

	if passed < 1:
		print("FAIL: Output log shown below")
		print(test_output)

		return False
	else:
		matches = re.findall(r"---\nA\d:\s+(\d+)\sA\d:\s+(\d+)\sA\d:\s+(\d+)\sA\d:\s+(\d+)\nB\d:\s+(\d+)\sB\d:\s+(\d+)\sB\d:\s+(\d+)\sB\d:\s+(\d+)\n", test_output)
		for match in matches:
			A = np.append(A, data_to_values(match[0:4], w, signed))
			B = np.append(B, data_to_values(match[4:8], w, signed))

		np.savez_compressed(data_file, [A, B])

		return True


def plot_results(n, w, signed, acc):
	data_file = f"{test_result_dir}/results_{w}_{'mac' if acc else 'mul'}_{'signed' if signed else 'unsigned'}.npz"

	if os.path.exists(data_file):
		data = np.load(data_file)
		A = data["arr_0"][0]
		B = data["arr_0"][1]

	else:
		return

	min_value = min_n_bit_value(w, signed)
	max_value = max_n_bit_value(w, signed)
	plt.scatter(A, B)
	plt.axis([min_value, max_value, min_value, max_value])
	plt.show()

def calculate_coverage(n, w, signed, acc):
	data_file = f"{test_result_dir}/results_{w}_{'mac' if acc else 'mul'}_{'signed' if signed else 'unsigned'}.npz"

	if os.path.exists(data_file):
		data = np.load(data_file)
		A = data["arr_0"][0]
		B = data["arr_0"][1]
		unique_points = len(set(zip(A, B)))
		possible_points = ((2**w)-1) ** 2

		return unique_points/possible_points

	else:
		return -1



def build_cfg_string(w, signed, acc):
	return str(log(w/8)/log(2) + ((1 if acc else 0) << 2) + ((1 if signed else 0) << 3))
		
def data_to_values(tup, w=8, signed = False):
	data = [int(x) for x in tup]
	if w == 8:
		results = data
	elif w == 16:
		results = [data[0] + (data[1] << input_width), data[2] + (data[3] << input_width)]
	else:
		results = [data[0] + (data[1] << input_width) + (data[2] << (2*input_width))+ (data[3] << (3*input_width))]

	if signed:
		signed_results = [unsigned_to_signed(x, w) for x in results]
		return signed_results
	else:
		return results

def max_n_bit_value(n, signed):
	if (signed):
		return (2 ** (n-1)) - 1
	else:
		return (2 ** n) - 1

def min_n_bit_value(n, signed):
	if (signed):
		return -(2 ** (n-1))
	else:
		return 0

def unsigned_to_signed(x, n):
	if x > max_n_bit_value(n, True):
		return x - (1 << n)
	else:
		return x


if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument('-t', help='Set coverage target for configuration (float between 0 and 1)', type=float, default=0.0)
  parser.add_argument('-n', help='Number of tests to run (per cycle if target is set)', type=int, default=100)
  parser.add_argument('-w', help='Set width of MAC operations', type=int, default = 8)
  parser.add_argument('--acc', help='Turn on accumulate for MAC', action='store_true', default = False)
  parser.add_argument('--signed', help='Turn on signed operations for MAC', action='store_true', default = False)
  parser.add_argument('--show', help='Show regression results', action='store_true', default=False)
  parser.add_argument('--clean', help='Clean before performing regression', action='store_true', default = False)
  args = parser.parse_args()


  build_simulator(args.clean)
  if args.t > 0.0:
  	print("---RUNNING IN COVERAGE MODE---")
  	last_result = True
  	coverage = 0.0
  	while (coverage < args.t and last_result):
  		if coverage < 0.0:
  			print("ERROR: Calculating coverage failed, will exit now")
  			exit(-1)

  		print(f"INFO: Current coverage: {coverage}")

  		last_result = run_simulator(args.n, args.w, args.signed, args.acc)
  		coverage = calculate_coverage(args.n, args.w, args.signed, args.acc)


  	if last_result == False:
  		"ERROR: Some test failed while gather coverage, results are shown above"
  	else:
  		print("---COVERAGE TARGET HIT---")
  else:
  	run_simulator(args.n, args.w, args.signed, args.acc)

  if (args.show):
  	plot_results(args.n, args.w, args.signed, args.acc)


