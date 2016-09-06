import socket
import sys
import os
import time

# Create a TCP/IP socket
sock = None

# Connect the socket to the port where the server is listening
server_address = ''

amount_received = 0
file_found = False

# client always running unless break
while True:
    message = raw_input('Enter your command.\n')
    
    if(message.startswith("CONNECT")):
        server_address = (message.split(',')[1],int((message.split(',')[2])))
        print >>sys.stderr, 'connecting to %s port %s' % server_address
        # setup socket object
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # connect to a server with address and port provided
        sock.connect(server_address)
        
    elif(sock == None):
        print "Connect to a server first"

    else:
        
        if(message == "QUIT"):
            quit()
        elif(message == "BYE"):
            print 'Bye..'
            # send BYE to server and close the socket
            sock.sendall(message)
            sock.close()
            sock = None
        elif(message.startswith("LIST")):
            # send list to the server and print out its response
            sock.sendall(message)
            data = sock.recv(1028)
            print >>sys.stderr, 'received "\n%s"' % data

            
        elif(message.startswith("READ")):
            if(len(message.split(',')) == 2):

                # Send data
                sock.sendall(message)
                # the next receive will be the file size from the server
                data = sock.recv(64)
                # if the next received data is ERROR: then something went wrong on the server side
                if(data.startswith("ERROR:")):
                   print >>sys.stderr, '"%s"' % data
                else:
                    filesize = int(data)
                    amount_received = 0
                    # open the file for writing in bytes
                    f1 = open(message.split(',')[1], 'wb')
                    
                    while amount_received <= filesize:
                    # keep receving the writing to the file untill amount received is greater or equal to the file size
                        try:
                            data = sock.recv(64)
                            f1.write(data)
                            amount_received = len(data) + amount_received
                            print str(data)
                        except:
                            
                            f1.close()
                            os.remove(f1.name)
                            sock = None
                            break
                        #print len(data)
                       # if (time.time() > timeout):
                           # print "time out"
                           # break
                    if(amount_received == filesize):
                         print >>sys.stderr, 'File Received.'
                    f1.close()
            else:
                print '\nSeparate the file name and READ with comma'
        elif(message.startswith("WRITE")):
            if(len(message.split(',')) == 2):
                file_found = False
                # loop the directory to find the file given using os.listdirt
                for files in os.listdir(os.getcwd()):
                    if(files == message.split(',')[1]):
                        file_found = True
                        # file is found, get the filesize to server for error handling
                        sock.sendall(message + ','+ str(os.path.getsize(os.getcwd() + "\\" + files)))

                        # open the file for reading, and send each line to the server
                        f1 = open(message.split(',')[1],'rb')
                        for line in f1:
                            sock.sendall(line)
                        
                        # close the file, the next recevied data will include whether the transfer was succesful or not
                        f1.close()
                        data = sock.recv(1028)
                        if(data != ""):
                            print >>sys.stderr, '%s' % data
                            
                if(file_found == False):
                    # file not found print back error message
                    print "\nFile is not in the current directory and include the extension"
            else:
                print "\nSeparte the file name and Write with comma"
