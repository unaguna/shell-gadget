Describe 'hashlist.sh'

    It 'show hashes of files in the root-directory'
        When call hashlist.sh ./spec/sampledir/sample_left

        The word 1 of line 1 of output should equal '87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7'
        The word 2 of line 1 of output should equal './a.txt'
        The word 1 of line 2 of output should equal '0263829989b6fd954f72baaf2fc64bc2e2f01d692d4de72986ea808f6e99813f'
        The word 2 of line 2 of output should equal './b.txt'
        The word 1 of line 3 of output should equal 'a3a5e715f0cc574a73c3f9bebb6bc24f32ffd5b67b387244c2c909da779a1478'
        The word 2 of line 3 of output should equal './c.txt'
        The word 1 of line 4 of output should equal '4355a46b19d348dc2f57c046f8ef63d4538ebb936000f3c9ee954a27460dd865'
        The word 2 of line 4 of output should equal './dir/1.txt'
        The word 1 of line 5 of output should equal '53c234e5e8472b6ac51c1ae1cab3fe06fad053beb8ebfd8977b010655bfdd3c3'
        The word 2 of line 5 of output should equal './dir/2.txt'
        The word 1 of line 6 of output should equal 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
        The word 2 of line 6 of output should equal './s'
        The word 3 of line 6 of output should equal 's.txt'
        The lines of output should equal 6
    End

    It 'show hashes of files in the target-directory'
        When call hashlist.sh -t sample_left ./spec/sampledir

        The word 1 of line 1 of output should equal '87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7'
        The word 2 of line 1 of output should equal 'sample_left/a.txt'
        The word 1 of line 2 of output should equal '0263829989b6fd954f72baaf2fc64bc2e2f01d692d4de72986ea808f6e99813f'
        The word 2 of line 2 of output should equal 'sample_left/b.txt'
        The word 1 of line 3 of output should equal 'a3a5e715f0cc574a73c3f9bebb6bc24f32ffd5b67b387244c2c909da779a1478'
        The word 2 of line 3 of output should equal 'sample_left/c.txt'
        The word 1 of line 4 of output should equal '4355a46b19d348dc2f57c046f8ef63d4538ebb936000f3c9ee954a27460dd865'
        The word 2 of line 4 of output should equal 'sample_left/dir/1.txt'
        The word 1 of line 5 of output should equal '53c234e5e8472b6ac51c1ae1cab3fe06fad053beb8ebfd8977b010655bfdd3c3'
        The word 2 of line 5 of output should equal 'sample_left/dir/2.txt'
        The word 1 of line 6 of output should equal 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
        The word 2 of line 6 of output should equal 'sample_left/s'
        The word 3 of line 6 of output should equal 's.txt'
        The lines of output should equal 6
    End

    It 'show hashes of files in the root-directory filterd by condlist'
        tmp_condlist=`mktemp`

        {
            echo D ./dir
            echo A /dir/ap
        } > "$tmp_condlist"

        When call hashlist.sh -f "$tmp_condlist" ./spec/sampledir/sample_left

        The word 1 of line 1 of output should equal '87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7'
        The word 2 of line 1 of output should equal './a.txt'
        The word 1 of line 2 of output should equal '0263829989b6fd954f72baaf2fc64bc2e2f01d692d4de72986ea808f6e99813f'
        The word 2 of line 2 of output should equal './b.txt'
        The word 1 of line 3 of output should equal 'a3a5e715f0cc574a73c3f9bebb6bc24f32ffd5b67b387244c2c909da779a1478'
        The word 2 of line 3 of output should equal './c.txt'
        The word 1 of line 4 of output should equal 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
        The word 2 of line 4 of output should equal './s'
        The word 3 of line 4 of output should equal 's.txt'
        The lines of output should equal 4

        rm -f "$tmp_condlist"
    End

    It 'raises error with unexist root-directory'
        When call hashlist.sh ./spec/sampledir/not_exists

        The status should not equal 0
        The lines of output should equal 0
        The error should include 'spec/sampledir/not_exists'
    End

    It 'raises error with unexist target-directory'
        When call hashlist.sh -t not_exists ./spec/sampledir/sample_left

        The status should not equal 0
        The lines of output should equal 0
        The error should include 'not_exists'
    End

    It 'raises error with unexist path_filter_list'
        When call hashlist.sh -f not_exists ./spec/sampledir/sample_left

        The status should not equal 0
        The lines of output should equal 0
        The error should include 'not_exists'
    End

End
