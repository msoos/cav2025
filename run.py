#!/usr/bin/python3
import subprocess
import os
import argparse
import psutil

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
    print(f'Number of threads: {args.threads}')
    print(f'Number of proj and unproj: {args.num}')
    print(f'Therefore total: {args.num*2}')
    print(f'Rebuild: {args.rebuild}')
    print(f'Timeout: {args.tlimit}')
    mem=psutil.virtual_memory().total  # total physical memory in Bytes
    print(f"Total memory: {mem / (1024 ** 3):.2f} GB")
    if mem < (8*args.threads) * (1024 ** 3):
        print("ERROR: This is not going to work, you need num_threads * 9 GM of memory")
        print("ERROR: Please follow instructions in README.md. It's NOT enough to have that much memory\
in your host, you need to expose it to the container.")
        exit(1)

    print(args)
    if args.rebuild:
        print("rebuilding ganak, with ALL dependent libraries except external ones like mlpack, etc.")
        os.chdir("../ganak/build/")
        subprocess.run(["sh", "rebuild_static_all_release.sh"])
        os.chdir("../../run/")

    with open("all_runner.sh", "w") as f:
        f.write("#!/bin/bash\n")
        f.write('pwd\n')
        f.write('rm -rf scratch\n')
        f.write('rm -rf out*\n')
        f.write('rm -f all_runner.sh\n')
        for i in range(0, args.threads):
            torun=f"./sub_runner.sh {args.num} {args.threads} {args.tlimit} {i} &\n"
            f.write(torun)
            f.write("sleep 1\n")
        f.write("wait\n")
        f.write("echo \"All done\"\n")
        f.close()
        print("ok")
    subprocess.run(["chmod", "+x", "./all_runner.sh"])
    subprocess.run(["./all_runner.sh"])
    exit(0)

if __name__ == '__main__':
    main()
