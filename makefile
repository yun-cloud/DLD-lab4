VLOG=		ncverilog
VLOGARG=	+access+r
HEAD=		header.v
SRC=		Adder32.v ALU.v GCD.v testbench.v
#SRC_syn=	
SDF=		+define+SDF
TMPFILE=	*.log INCA_libs
RM=		-rm -rf

all :: sim

sim :
	$(VLOG) $(VLOGARG) $(HEAD) $(SRC)

syn :
	$(VLOG) $(VLOGARG) $(SRC_syn) $(SDF) $(HEAD)

check :
	$(VLOG) -c $(SRC)

clean :
	$(RM) $(TMPFILE)

