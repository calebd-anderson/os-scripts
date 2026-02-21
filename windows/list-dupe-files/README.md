# find-duplicates
## Reports duplicate files in a working directory and subdirectories using SHA1 comparison.

### Example output to desktop named \"n_duplicates.txt\" (where n is the number of duplicates found):  

Does provide actual fully qualified path i.e. rather than [C:\\...] for example.  

> 4 duplicates found in "[C:\\...]\test_dir".
> 
> SHA1: 1ce7f9817298fd474e77ef41ad28472a8455056a  
> Size: 6 bytes.  
Paths:  
[C:\\...]\test_dir\child\d_file - Copy.txt  
[C:\\...]\test_dir\child\d_file.txt  
> 
> SHA1: 80c8c59a8be1c0f2aad9eb9ad44685ff633c2747  
> Size: 6 bytes.  
Paths:  
[C:\\...]\test_dir\b_file - Copy.txt  
[C:\\...]\test_dir\b_file.txt  
>   
> SHA1: f494d38e8bb084892c5c27efc0f1891dc69e9364  
> Size: 6 bytes.  
Paths:  
[C:\\...]\test_dir\a_file.txt  
[C:\\...]\test_dir\child\a_file.txt  
> 
> SHA1: HASH_ERROR-FILE_INVALID_SIZE  
> Size: 0 bytes.  
Paths:  
[C:\\...]\test_dir\data - Copy.txt  
[C:\\...]\test_dir\data.txt  
