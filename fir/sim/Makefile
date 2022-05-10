## 
## -------------------------------------------------------------
##    Copyright 2004-2009 Synopsys, Inc.
##    All Rights Reserved Worldwide
## 
##    Licensed under the Apache License, Version 2.0 (the
##    "License"); you may not use this file except in
##    compliance with the License.  You may obtain a copy of
##    the License at
## 
##        http://www.apache.org/licenses/LICENSE-2.0
## 
##    Unless required by applicable law or agreed to in
##    writing, software distributed under the License is
##    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
##    CONDITIONS OF ANY KIND, either express or implied.  See
##    the License for the specific language governing
##    permissions and limitations under the License.
## -------------------------------------------------------------
##

DV_DIR = ../dv/
RTL_DIR = ../rtl/

all: clean comp run cov

clean:
	rm -rf simv* csrc *.log vc_hdrs.h ucli.key urg* *.vpd

comp:
	vcs -cm line+tgl+branch -sverilog -timescale=1ns/10ps -ntb_opts uvm-1.2 +incdir+ $(DV_DIR)fir_seq_pkg.sv $(DV_DIR)fir_cfg_pkg.sv $(DV_DIR)fir_comp_pkg.sv $(DV_DIR)fir_uvm_top.sv $(RTL_DIR)fir_filter.v -l comp.log -R +vcs+vcdpluson -debug_acc+pp+dmptf -debug_region+cell+encrypt 

run:
	simv -cm line+tgl+branch +UVM_NO_RELNOTES +UVM_VERBOSITY=UVM_LOW -l run.log

cov:
	urg -dir simv.vdb 
