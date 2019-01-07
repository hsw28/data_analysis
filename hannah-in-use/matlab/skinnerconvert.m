function f = skinnerconvert(first_LIGHTtime_from_posfile, skinnervector);

tm = first_LIGHTtime_from_posfile;
difference = tm - skinnervector(1,1);

skinnervector = skinnervector + difference;
f = skinnervector;
