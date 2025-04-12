#!/usr/bin/python3
import subprocess
import os
import argparse

def main():
    # Create the parser
    parser = argparse.ArgumentParser(description="Run the system")

    parser.add_argument(
        '--threads',
        type=int,
        default=6,
        choices=range(1, 17),  # Accept integers from 1 to 16
        help='Number of threads (1-16)'
    )

    parser.add_argument(
        '--num',
        required=False,
        type=int,
        default=20,
        help='How many CNFs to run for proj and unproj. So 20 means 20 proj and 20 unproj. Default is 20'
    )

    parser.add_argument(
        '--tlimit',
        type=int,
        default=600,
        help='Timeout in seconds for each CNF. Default is 600'
    )

    parser.add_argument(
        '--rebuild',
        action="store_true",
        default=False,
        help='Rebuild ganak'
    )

    # Parse the arguments
    args = parser.parse_args()

    # Print the parsed arguments
    print(f'Threads: {args.threads}')
    print(f'Number of proj and unproj: {args.num}')
    print(f'Therefore total: {args.num*2}')
    print(f'Rebuild: {args.rebuild}')

    print(args)
    if args.rebuild:
        print("rebuilding ganak, with ALL dependent libraries except external ones like mlpack, etc.")
        subprocess.run(["pwd"])
        os.chdir("../ganak/build/")
        subprocess.run(["pwd"])
        subprocess.run(["sh", "rebuild_static_all_release.sh"])
        os.chdir("../../run/")

    for i in range(0, args.threads):
        torun=["sub_runner.sh", f"{args.num}", f"{args.threads}", f"{args.tlimit}", f"{i}"]
        print(torun)
        #subprocess.run(torun)

if __name__ == '__main__':
    main()

