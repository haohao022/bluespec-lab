all:
	bsc -u -sim -simdir . -bdir . -info-dir . -keep-fires -cpp \
	  -p %/Prelude:%/Libraries:%/Libraries/BlueNoC -g mkTests TestShifterPipe.bsv
	bsc -e mkTests -sim -o ./out -simdir . \
	  -p %/Prelude:%/Libraries:%/Libraries/BlueNoC -bdir . -keep-fires
	./out

clean:
	rm -rf *.bo *.ba *.h *.o out* *.cxx
