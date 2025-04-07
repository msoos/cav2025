#!/usr/bin/python3
import subprocess
import os
import argparse

def main():
    # Create the parser
    parser = argparse.ArgumentParser(description="Run the system")

    # Add the --threads argument
    parser.add_argument(
        '--threads',
        type=int,
        required=True,
        choices=range(1, 17),  # Accept integers from 1 to 16
        help='Number of threads (1-16)'
    )

    # Add the --run argument
    parser.add_argument(
        '--run',
        required=True,
        choices=['full', 'partial', 'small'],  # Accept specific string values
        help='Run type: full, partial, or small'
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
    print(f'Run type: {args.run}')
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
        torun=["sub_runner.sh", f"{args.run}", f"{args.threads}", f"{i}"]
        print(torun)
        #subprocess.run(torun)

if __name__ == '__main__':
    main()

