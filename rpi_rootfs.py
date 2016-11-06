#!/usr/bin/env python
#
#
#

import os
import subprocess
import sys
import re

## Syncing Directory/File Pattern
rsync_include = ['lib','usr','opt/vc']

## Rsync Options
rsync_cmd = ['/usr/bin/rsync']
rsync_options = ['-rRlvu', '--stats',  '--delete-after', '--include=usr/share/pkg*', '--include=etc/ld.so.*' ]

################################################################################
#
# Rsync
#
################################################################################
## Error code from rsync manual page
def rsync_err_msg(retcode):
    errorcode_to_msg  = {
        1: "Syntax or usage error",
        2: "Protocol incompatibility",
        3: "Errors selecting input/output files, dirs",
        4: "Requested  action not supported: an attempt was made to manipulate 64-bit files on a platform\
that cannot support them; or an option was specified that is supported by the client and  not\
by the server.",
        5: "Error starting client-server protocol",
        6: "Daemon unable to append to log-file",
        10: "Error in socket I/O",
        11: "Error in file I/O",
        12: "Error in rsync protocol data stream",
        13: "Errors with program diagnostics",
        14: "Error in IPC code",
        20: "Received SIGUSR1 or SIGINT",
        21: "Some error returned by waitpid()",
        22: "Error allocating core memory buffers",
        23: "Partial transfer due to error",
        24: "Partial transfer due to vanished source files",
        25: "The --max-delete limit stopped deletions",
        30: "Timeout in data send/receive",
        35: "Timeout waiting for daemon connection"
    }
    return errorcode_to_msg.get(retcode, "error code not found")

#
def rsync_get_include_option(user):
    return ''.join([user] + [':/{'] + [','.join(rsync_include)] + ['}'])

#
def process_rsync_rootfs(user, path):
    # Building rsync command line
    rsync_full_command = rsync_cmd + rsync_options  + ['--exclude-from=rpi_rootfs_exclude.txt'] \
            + [rsync_get_include_option(user)] + [path]
    #print(rsync_full_command)
    ret = subprocess.call(rsync_full_command, shell=False)
    if ret != 0:
        print("Rsync error : %s" % rsync_err_msg( ret) )
    return ret


################################################################################
#
# Convert absolute link to relative link
#   : This content copied from sysroot-relativelinks.py in YoctoProejct
#
################################################################################
## 
def relativelinks_handlelink(topdir, filep, subdir):
    link = os.readlink(filep)

    if link[0] != "/":
        return
    if link.startswith(topdir):
        return

    if link.startswith('/'):
        print("File Starting %s link %s" % (filep,link))

    #print("Replacing %s with %s for %s" % (link, os.path.relpath(topdir+link, subdir), filep))
    os.unlink(filep)
    os.symlink(os.path.relpath(topdir+link, subdir), filep)


def process_relativelinks(path):

    topdir = os.path.abspath(path)

    for subdir, dirs, files in os.walk(topdir):
        for f in files:
            filep = os.path.join(subdir, f)
            if os.path.islink(filep):
                #print("Considering %s, Subdir: %s" % (filep, subdir))
                relativelinks_handlelink(topdir, filep, subdir) 


################################################################################
#
# making pkg-config links
#
################################################################################

def symlink_force(target, link_name):
    try:
        os.symlink(target, link_name)
    except OSError, e:
        if e.errno == errno.EEXIST:
            os.remove(link_name)
            os.symlink(target, link_name)
        else:
            raise e

def process_pkgconfig_link(path):
    # 
    pkgconfig_path  = os.path.abspath(path)+'/usr/lib/arm-linux-gnueabihf/pkgconfig'
    if(os.path.exists(pkgconfig_path)):
        print("pkg config: %s" % pkgconfig_path)
        for subdir, dirs, files in os.walk(pkgconfig_path):
            for f in files:
                filep = os.path.join(subdir, f)
                target_packageconfig = "../../lib/arm-linux-gnueabihf/pkgconfig/" + f
                link_packageconfig =  os.path.abspath(path) + "/usr/share/pkgconfig/" + f
                print("source %s target %s" % (target_packageconfig, link_packageconfig))
                symlink_force(target_packageconfig, link_packageconfig)
    else:
        sys.stderr.write('ERROR: pkg-config does not exist : %r\n\n' % pkgconfig_path)

################################################################################
#
# making include/sys links
#
################################################################################

def process_sys_include_link(path):
    # 
    sys_include_link_path  = os.path.abspath(path)+'/usr/include/arm-linux-gnueabihf/sys'
    if(os.path.exists(sys_include_link_path)):
        for subdir, dirs, files in os.walk(sys_include_link_path):
            print ("SUBDIR : %s" % subdir )
            print ("SUBDIR : %s" % dirs )
            for f in files:
                filep = os.path.join(subdir, f)
                target_sys_include = "../arm-linux-gnueabihf/sys/" + f
                link_sys_include =  os.path.abspath(path) + "/usr/include/sys/" + f
                print("source %s target %s" % (target_sys_include, link_sys_include))
                symlink_force(target_sys_include, link_sys_include)
    else:
        sys.stderr.write('ERROR: pkg-config does not exist : %r\n\n' % pkgconfig_path)

def process_include_link(path):
    include_link_path  = os.path.abspath(path)+'/usr/include/arm-linux-gnueabihf'
    if(os.path.exists(include_link_path)):
        for subdir, dirs, files in os.walk(include_link_path):
            print ("SUBDIR : %s" % subdir )
            print ("DIRS : %s" % dirs )
            print ("FILES : %s" % dirs )
            #for f in files:
            #    filep = os.path.join(subdir, f)
            #    target_sys_include = "../arm-linux-gnueabihf/sys/" + f
            #    link_sys_include =  os.path.abspath(path) + "/usr/include/sys/" + f
            #    print("source %s target %s" % (target_sys_include, link_sys_include))
            #    #symlink_force(target_sys_include, link_sys_include)
    else:
        sys.stderr.write('ERROR: pkg-config does not exist : %r\n\n' % pkgconfig_path)

################################################################################
#
# GNU linker script fixing
# This function will search the entire rootfs path with 'grep' command.
#
################################################################################
def inplace_change(filename, old_string, new_string):
    # Safely read the input filename using 'with'
    with open(filename) as f:
        s = f.read()
        if old_string not in s:
            print '"{old_string}" not found in {filename}.'.format(**locals())
            return

    # Safely write the changed content, if found in the file
    with open(filename, 'w') as f:
        print 'Changing "{old_string}" to "{new_string}" in {filename}'.format(**locals())
        s = s.replace(old_string, new_string)
        f.write(s)


def fix_process_ld_scripts(path, filename):
    file_contents = [] 
    if not os.path.exists(filename):
        print("linker script file does not exist: %s" % filename )

    with open(filename) as fstream:
        file_contents = fstream.readlines()

    #
    # Check whether this file is GNU linker script
    if not '/* GNU ld script' in file_contents[0]:
        # stop fixing link script
        print("file is not linker script: %s" % filename )
        return

    #
    # Search 'GROUP' keyword in file content
    for index, line_content in enumerate( file_contents ):
        if 'GROUP' in line_content:
            token_list = [x for x in re.split('[(), ]', line_content) if x]
            for index, item in enumerate(token_list):
                if os.path.exists(path + item):
                    if item[0] == "/":
                        # This means that this item have absolute path, it need to be fixed
                        split_head, split_tail = os.path.split(filename)
                        relpath = os.path.relpath(path+item, split_head)
                        inplace_change(filename, item, relpath)


process_ld_scripts_command = [ '/bin/grep', '-rl', '--exclude=*', '--include=*.so', '\"GNU ld script\"', '*' ]
def process_ld_scripts(path):
    grep_command = ' '.join(process_ld_scripts_command)
    proc = subprocess.Popen(grep_command,stdout=subprocess.PIPE, shell=True)
    for line in proc.stdout:
        #the real code does filtering here
        fix_process_ld_scripts(path, line.strip())

################################################################################
#
# Main Function
#
################################################################################
def main(argv):
    if len(argv) != 3:
        sys.stderr.write('Usage: ' + argv[0] + ' <user@hostname> <rootfs path>\n')
        return 1

    if not sys.platform.startswith('linux'):
        sys.stderr.write('RPi RootFS does not support this platform: %r\n\n' % sys.platform)
        return 1

    #process_sys_include_link(argv[2])
    #process_include_link(argv[2])
    #return 1

    print("################################################################################")
    print("###\n### rootfs syncing from %s\n###" % argv[1] )
    print("################################################################################")
    ret = process_rsync_rootfs(argv[1], argv[2])
    if ret != 0:
        ## Failed to rsync the remote file system, aborting!
        return ret

    print("################################################################################")
    print("###\n### fixing absolute links\n###" )
    print("################################################################################")
    process_relativelinks(argv[2])

    print("################################################################################")
    print("###\n### linking pkgconfig on /usr/share/pkginfo \n###" )
    print("################################################################################")
    process_pkgconfig_link(argv[2])

    print("################################################################################")
    print("###\n### fixing ld scripts absolute path to relative path \n###" )
    print("################################################################################")
    process_ld_scripts(argv[2])

    #print("################################################################################")
    #print("###\n### linking include/sys file  \n###" )
    #print("################################################################################")
    #process_sys_include_link(argv[2])

if __name__ == '__main__':
    sys.exit(main(sys.argv))



