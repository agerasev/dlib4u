COMPILER=dmd
UNITTEST_FLAGS=-w -unittest -main -od"unittest"
FLAGS=-w -c

mat_unittest: l4u/la/mat.d vec.o
	$(COMPILER) $(UNITTEST_FLAGS) l4u/la/mat.d vec.o -of"mat"

vec_unittest: l4u/la/vec.d
	$(COMPILER) $(UNITTEST_FLAGS) l4u/la/vec.d -of"vec"

mat.o: l4u/la/mat.d
	$(COMPILER) $(FLAGS) l4u/la/vec.d
	
vec.o: l4u/la/vec.d
	$(COMPILER) $(FLAGS) l4u/la/vec.d
