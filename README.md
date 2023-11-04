# Thrive Takehome Challenge

This repo is for the [Thrive](https://thrivemycareer.com/) takehome coding challenge.

## Running the `challenge.rb` script

To run the `challenge.rb` script, simply invoke the script using the `ruby` command. If the script runs successfully, the results will be saved in a file named `output.txt`, in the same directory. 

For example

```bash
$ ruby challenge.rb
Users: 35
Companies: 6
...................................
Done processing. Results in output.txt
Output passed verification
$ _
```
### Requirements

This script has been written and tested using Ruby v3.0.2.

It assumes that the `users.json` and `companies.json` files exist in the same directory. Both these files were provided with the challenge.

The script also automatically compares its results against the `example_output.txt` file that was provided with the challenge. Many thanks for providing the example output :)

## Development notes

Normally I would put classes like Company and User in their own files, but did not do so for this challenge so that the script could be delivered as a single rb file.

The script is designed to transparently handle some data formatting errors (e.g., token values provided as quoted strings), but will halt with exit code 1 if a company or user proves to be unparseable. For example, in the case of missing or mis-spelled attribute names, the script will attempt to write out exactly where the error occurred, and the halt so the user can find and fix the issue in the input data files.

**Dave Isaacs**  
_November 2023_