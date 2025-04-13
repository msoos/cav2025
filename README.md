# Overview
The system is a VirtualBox VM for x64 CPU cores, with at least SSE4.2 support,
which all systems should have that are relatively recent (<6 years old).
Unfortunately virtualbox does NOT emulate instructions the underlying CPU does
not have. It's not an emulator, it's a hypervisor.

You MUST give at least 64GB of memory and 6 CPU cores to the system if you even
partially wish to recreate the results. This MUST be done via VirtualBox
manager -> click on the VM -> settings -> system -> processor and memory. If
you fail to to this, things will fail in case you want to re-create
results.

Unfortunately, our experiments require a lot of CPU power, and each
instance also requires at least 9GB of memory. Even so, we will restrict d4,
gpmc and SharpSAT-TD to use 9GB of memory instead of the 45GB as per the paper
experiments. We will explain this choice later -- but suffice to say, unless
you are willing to wait for 21 days, and have a machine with 1TB of memory and
22 cores, these restrictions are necessary.

# Logging in
The user is vboxuser, the hostnamer is vbox, the password is "debian". The root
password is also "debian". You can "su" to root, and then you can install
things, if you like.

If you wish to, you can SSH into the system, ssh server is started at startup.
It should be in a NAT, so simply add a NAT redirect, e.g. Host IP 127.0.0.1,
Host port 2222 to Guest IP 10.0.2.15 (replace with the IP your vboxmanager
provides) and port 22. Then on your host, you can ssh into the VM using `ssh -p
2222 vbox@127.0.0.1`

There is no NEED to ssh in. I find it easier, but you can just use the graphical
user interface, if you like, run a terminal, etc. To view the graphs, though,
you likely want to log in normally, not via ssh.

# Obtaining and building the counters
The non-ganak counters (d4, gpmc, SharpSAT-TD) cannot and should not be built.
Instead, they should be used as they have been provided to the Model Counting
Competition in 2024 by the authors. They are present in the directory:
```
/home/vboxuser/devel/run/mccomp2024
```

To rebuild Ganak from source:
```
cd /home/vboxuser/devel/ganak/build
./rebuild_static_all_release.sh
```

You can examine that script to ensure that indeed everything gets rebuilt from
source that isn't a well-known library like the GNU multiprecision library.
The build script calls other build scripts that wipe all compiled files
and rebuild everything from scratch. It builds everything needed, from CaDiCal
to CadiBack to Arjun, Approxmc, BreakID, Ganak, etc. All these are provided and
publicly available. In fact, all of them are a git repository, with public GIT
commits. You can check them out. All are either MIT or LGPLv2 licensed. In
fact, only BreakID (more precisely, its bliss library) is LGPLv2, and it's not
even used, but compiled in. Hence I could have the final binary MIT, but
currently, it's LGPLv2.

Notice that this builds a static 64-bit x86 binary that will run on all Linux
platforms that have a relatively recent kernel and SSE4.2 support. In order to
keep the system 100% as submitted, we have not changed the code, but the newest
Ganak, as present on GitHub (branch "nodonkey"), compiles to everything,
including Arm, Mac, and even WASM. Hence we find this as reusable as possible,
without messing with the code that was submitted when the paper was submitted.

There is only one Ganak binary. The different configurations are simply different
command line arguments, turning off various features. ScalMC is simply Ganak
with everything turned on, noted as "out-ganak-also-extend-d-set"

**Hence, "out-ganak-also-extend-d-set" is all features turned on, noted
as "ScalMC" in the paper.** We are in fact the original Ganak authors. Baseline
is simply all new features turned off.

# MCComp2024 and MCComp2023 CNF instances
The MCComp CNF instances are in the directories:
```
/home/vboxuser/devel/run/cnfs/mccomp2023
/home/vboxuser/devel/run/cnfs/mccomp2024
```

There are also directories here, e.g. `/home/vboxuser/devel/run/cnfs/all` that contain
symlinks to these files.

# The logs and results reported in the paper
Firstly to assuage any worries: we'll get to reproducing some of these. In the
meanwhile, let's talk about the logs and the reported values. Please go to the
directory:
```
cd /home/vboxuser/devel/ganak/build/data
```

Here, you will find the directories:
```
out-ganak-baseline
out-ganak-basic-sat-and-chronobt
out-ganak-also-enhanced-sat
out-ganak-also-dual-indep
out-ganak-also-extend-d-set
out-d4
out-gpmc
out-sharptd
```

These are the logs for the various counters (d4, gpmc, SharpSAT-TD) and for
various configurations of ganak (baseline, etc.). They are full logs, with the
logfile and the data from the `/usr/bin/time` command. For example, these two
files in the directory `/home/vboxuser/devel/ganak/build/data/out-ganak-also-dual-indep`:
```
mc2024_track4_188.cnf.gz.out_ganak
mc2024_track4_188.cnf.gz.timeout_ganak
```
The first is the output of ganak with everything turned on (i.e. "ScalMC"), the
2nd is the output of the `time` command, which gives accurate memory, time,
etc. measures. We can parse the logs via:

```
cd /home/vboxuser/devel/ganak/build/data
./clean.sh # removes ALL parsed logs and data
./get_data_ganak.py
````

Please be _patient_ as this will take a while. It will parse the logs, and
create an sqlite database, and a CSV file. The CSV file is in the directory
`/home/vboxuser/devel/ganak/build/data`, and is called `mydata.csv`. The SQLite
database is called `mydb.sql`, and is in the same directory.

You can verify by examining get_data_ganak.py that this indeed deletes the SQL
databasea `mydb.sql` and recreates it, along with a CSV file mydata.csv for ALL
DATA. Not just Ganak, but all. If you so wish, you can examine the SQL database and
the CSV file.

Then, to get the tables for projected, unprojected, and proj+unproj run, one by one,
and examine the results:

```
cd /home/vboxuser/devel/ganak/build/data
./create_graphs.py --proj
[.. examine output and eps ..]
./create_graphs.py --unproj
[.. examine output and eps ..]
./create_graphs.py --all
[.. examine output and eps ..]
```

Each will try to launch an `okular run.eps` window with the graph. If you
logged in as vboxuser, via the desktop, it will pop up. If you are
ssh'ing in, you can copy the `run.eps` file to your host, and view it.

To get the table for the Ganak ablation study, run:
```
cd /home/vboxuser/devel/ganak/build/data
./create_graphs.py --ganak
[.. examine output and eps ..]
```

Which again will attempt at calling "okular run.eps" to display the graph.
You should be able to see that it's identical to the one in the paper.

To get the example CNF table from mccomp2023 track3 benchmark 149, run:
```
cd /home/vboxuser/devel/ganak/build/data
./create_graphs.py --example
```

This takes the SQLite database, and runs the queries to get the data as per the paper.

To get the numbers reported in the paragraph regarding the number of variables,
S-set, D-set, extension, extension time etc, run:
```
cd /home/vboxuser/devel/ganak/build/data
./create_graphs.py --numbers
```

Which will result in:
```
median vars:  2297
median projected vars:  208
+--------+-----------+-----------+-------------------------+--------------------+-------------------+------------------------+-----------------------+
| 'data' | med S-set | med D-set | med num vars after simp | med syntactic ext. | med semantic ext. | med syntactic ext t(s) | med semantic ext t(s) |
+--------+-----------+-----------+-------------------------+--------------------+-------------------+------------------------+-----------------------+
| data   | 89        | 182       | 410                     | 9                  | 87                | 0.26                   | 44.74                 |
+--------+-----------+-----------+-------------------------+--------------------+-------------------+------------------------+-----------------------+
```

Which correspond to the numbers reported in the paper, and they are directly
pulled from the logs (and the SQLite DB, which we just created from the logs),
as can be verified by examining the code that prints them. Here, "med" means
median, "t" means time, and "ext" means extension.

# Reproducing the results
The issue we are faced with is that there are 200*4*2=1600 instances to run,
each requiring 45GB of memory for 3 of the non-Ganak counters, and 4
configurations, each requiring 9GB of memory for the various Ganak variants. So
just to run the 3 non-Ganak counters, on a machine with 1TB of memory and 22
cores, we'd need 218 hours, i.e. about 9 days. We'd need an additional 290
hours, or 12 days, to rerun Ganak (though that'd "only" require a machine with
22 cores and 200GB of RAM). That's likely not possible, partly because 21 days
is a bit much to wait, and partly because I'm assuming most people don't have a
machine with 1TB of memory and 22 cores. So I designed the system
to run SOME of the CNFs for a shorter, 10min runtime.

You will REQUIRE a machine with 64GB of memory, and 6 cores, and we'll restrict
all counters to 9GB of memory. This will NOT reproduce the exact same results,
but should give some approximation that hopefully will make the results
acceptable and hint at what we have reported. You are encouraged to compare the
logs that we have provided, as per above, to the logs that this system creates,
and verify that they largely match.

To re-iterate, you MUST give the VM 64GB of memory AND 6 cores. Please read the
introduction on how to do this. Unfortunately, VirtualBox does not allow me to
adjust this in a way that _your_ virtualbox will set it. You must set it.

The below will take 20 projected and 20 unprojected instances randomly selected
from the 1600 instances by running shuffle with a specific seed, and head -n 20
for projected and unprojected instances. So we will be left with 40
instances*(3 non-Ganak counter + 4 Ganak configurations)=280 experiments to
run, 10min (600 seconds) each, so that's 46h of runtime, which over 6 cores is
is about 8h of wall clock time. You can adjust the number of instances via
`--num 40` if you are willing to wait 16h, or `--tlimit 1200` if you are
willing to wait 1200 seconds (20min) per instance. So, e.g.
```
cd /home/vboxuser/devel/run
./run.py --num 40 --tlimit 1200
```
will run 40 instances, each for 20min, thereby taking ~32h of wall clock time(!).

WARNING: The process will NOT terminate its children if you start it and then
Ctrl-C. Instead, it will leave all the counters and shell scripts running, and
it will be a mess. In this case, reboot the VM, and start `./run.py` again. If you fail
to do this, your results will be very wrong and things will go weird.

## Running the experiments
Let's run the default setup, i.e. 20+20 instances, 10min each, 6 cores, 9GB of
memory each. Notice that we will run 41 instances, as we will add
`mc2023_track3_149.cnf` to the set so that `--example` will work:
```
cd /home/vboxuser/devel/run
./run.py --num 20 --tlimit 600
```

This will run for a while. Eventually, it will finish, writing "All done" to
the console:
```
Finished waiting rank ...
Finished waiting rank ...
All done
```

## Generating the results
You can examine how things went by looking into the `scratch/0`, `scratch/1`,
etc. directories, and checking out the corresponding `out_0`, `out_1`, etc.
text files. The results will be written to the `/home/vboxuser/run/out-...`
directories, similarly to the logs we provided.

Now you can run the same scripts as before (it's symlinked here):
```
cd /home/vboxuser/devel/run
./get_data_ganak.py
```

In order to parse the logs, and create the SQLite database and CSV file. Then:
```
cd /home/vboxuser/devel/run
./create_graphs.py --proj
[.. examine output and eps ..]
./create_graphs.py --unproj
[.. examine output and eps ..]
./create_graphs.py --all
[.. examine output and eps ..]
./create_graphs.py --ganak
[.. examine output and eps ..]
./create_graphs.py --numbers
[.. examine output ..]
./create_graphs.py --example
[.. examine output ..]
```

To get the tables and graphs, as before. The `--example` will always work,
as we always add the file `mc2023_track3_149.cnf` to the set.

Some graphs and data will not get generated in case you have assigned
too little time or too few instances, and e.g. nothing actually
terminated, or everything ran out of memory, etc. Empty data make for
bad graphs.

# A note on version numbers
During the running of the experiments, we ran with two different Ganak
versions that differ only in how the treewidth is printed and whether
contraction over the independent set during graph generation is controllable
via the command line. The two versions are:
```
dc50a0b26a874db7c50302f48232ca2b02eebe20 -- enhanced
d622244b9c938bd621980e9eaa286f5766ae40d1 -- original
```

This change does not influence the results other than what is printed when flow-cutter
is finished, which we never report on. You can check this via:
```
cd /home/vboxuser/devel/ganak/
git diff d622244b9c938bd621980e9eaa286f5766ae40d1 dc50a0b26a874db7c50302f48232ca2b02eebe20 src/
```

If you take a look at the version numbers in the logfiles:
```
$ cd /home/vboxuser/devel/ganak/build/data
$ grep revision out-ganak-also-enhanced-sat/mc2024_track2-random_194.cnf.gz.out_ganak
c o GANAK SHA revision d622244b9c938bd621980e9eaa286f5766ae40d1
c o GANAK compiled with gcc version 14.2.1 20240910c o CMS revision: 041c090adab92a47c0557edad0a0e0f5f4a6455e
c o Arjun SHA revision: fec6372dbbc076d455138fb32d64ebf4a2538b52
c o Arjun SBVA SHA revision: 5912435affe8c77ecf364093cea29e0fc5c1b5cb
$ grep CaDi out-ganak-also-enhanced-sat/mc2024_track2-random_194.cnf.gz.out_ganak
c o CaDiCaL 2.0.0 45850b35836122622a983e637251299cc16f3161
$ grep Vers out-ganak-also-enhanced-sat/mc2024_track2-random_194.cnf.gz.out_ganak
c o Version 0.2.1 d1c1a70a1be6bbc9ac606c356912a0ca70aaa2ec
```

Let's run an example, to get the version numbers:
```
$ cd /home/vboxuser/devel/run
$ ./ganak cnfs/all/mc2023_track3_107.cnf.gz > tmp # you have to be patient here, about 20s
$ grep revision tmp
c o GANAK SHA revision SOMEVERSION
c o GANAK compiled with gcc version 12.2.0c o CMS revision: 041c090adab92a47c0557edad0a0e0f5f4a6455e
c o Arjun SHA revision: fec6372dbbc076d455138fb32d64ebf4a2538b52
c o Arjun SBVA SHA revision: 5912435affe8c77ecf364093cea29e0fc5c1b5cb
$ grep CaDi tmp
c o CaDiCaL 2.0.0 45850b35836122622a983e637251299cc16f3161
$ grep Vers tmp
c o Version 0.2.1 d1c1a70a1be6bbc9ac606c356912a0ca70aaa2ec
$ rm tmp
```

Where everything matches, except for Ganak. The reason for this is that I
had to adjust the data gathering scripts so that it's easier for you
to run things (e.g. "--example"). We can check this:
```
cd /home/vboxuser/devel/ganak/
git diff dc50a0b26a874db7c50302f48232ca2b02eebe20 HEAD src/
```
which will give you an empty list -- no change at all to the code, only the scripts
under "scripts/" were changed to make it easier for you to run things.

Hence, all code that you are running is matching what was executed in the paper,
except for the Ganak version, which is only different in immaterial code, and
helper scripts to extract data, that you are using and is therefore immaterial
to the behaviour of the system.
