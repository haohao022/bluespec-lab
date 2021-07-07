# p1:
# 	utility-bins/smips -b simulator/procs/Unpipelined/2cyc_harvard.bsv \
# 	  -c all --run

p1:
	utility-bins/smips -b simulator/procs/ControlHazardOnly/pcMsg_epoch.bsv \
	  -c all --run

p2:
	utility-bins/smips -b simulator/procs/ControlHazardOnly/pcMsg_epoch_bypass.bsv \
	  -c all --run

clean:
	rm -r build/
