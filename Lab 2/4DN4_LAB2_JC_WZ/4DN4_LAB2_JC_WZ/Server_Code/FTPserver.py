#------------- SAMPLE THREADED SERVER ---------------
# Similar threading code can be found here:
# Python Network Programming Cookbook -- Chapter - 2
# Python Software Foundation: http://docs.python.org/2/library/socketserver.html



import socket
import threading
import SocketServer
import time
import random

import sys
import os

thread_counter = 0

# define a class to store the attributes of the files
class Files(object):
    name = None
    full_path = None
    size = None
    type = None
    
#creat a function to return a list of all the files
def getList():
    List_of_files = []
    curruent_path = os.getcwd()
    file_found = False
    response = ''
    # loop through all the files in the current directory and create a Files objects and append to List_of_files
    for files in os.listdir(curruent_path):
        new_file = Files()
        new_file.name = files
        new_file.full_path = curruent_path + "\\" + files
        new_file.size = os.path.getsize(curruent_path + "\\" + files)
        fileName, fileExtension = os.path.splitext(new_file.full_path)
        # tyeo if set for the file depending on its extension
        if (fileExtension == '.mov'):
            new_file.type = "viedo"
            List_of_files.append(new_file)
        elif (fileExtension == '.mp3'):
            new_file.type = "music"
            List_of_files.append(new_file)
        elif (fileExtension == '.jpg'):
            new_file.type = "picture"
            List_of_files.append(new_file)
    return List_of_files



class ThreadedTCPRequestHandler(SocketServer.BaseRequestHandler):

    def handle(self):
        global thread_counter
        thread_counter  += 1
        
        cur_thread = threading.current_thread()  # identify current thread

        thread_name = cur_thread.name   # get thread-number in python     
    
        print '\nServer Thread %s receives request: preparing response ' % thread_name
        # while loop to keep the connection alive untill user quits
        
        while (True):
            data = self.request.recv(1024)
            data = data.strip()
            if(data != ''):
                if(data.startswith('LIST')):
                    
                    print "\nLIST Command From %s" % thread_name
                    response = ""
                    # get list of files using the fucntion define above
                    List_of_files=getList()
                    for files in List_of_files:
                        # prepare the response
                        response = response + str(files.type)+ "\t " + str(files.name) + "\t size: " + str(files.size) + " bytes\n"
                    if(response == ""):
                        # send the response using request.sendall
                        self.request.sendall("There is no files in the directory")
                    else:
                        self.request.sendall(response)
                        response = ""
                    print "LIST Task Done for %s" % thread_name
                elif(data.startswith('READ')):
                    #get file list
                    List_of_files=getList()
                    if(len(data.split(',')) == 2):
                        filename = data.split(',')[1]
                        file_found = False
                        #loop through the list to check if the file exist
                        for files in List_of_files:
                            if(files.name == filename):
                                file_found = True
                                #send the file size to the client for error handling
                                self.request.sendall(str(files.size))
                                #change the directoy just in case
                                os.chdir(files.full_path[:len(files.full_path) - len(files.name)])
                                print "\nREAD Command From %s" %thread_name
                                print "Sending " + str(filename) + "to %s" %thread_name
                                # open the file in read byte mode for transfer
                                f1 = open(files.name, 'rb')
                                for line in f1:
                                    #send each line of the file using a for loop
                                    self.request.sendall(line)
                                # close the file after transfer
                                f1.close()
                        if(file_found == False):
                            #if file is not found, send error to the client for handling
                            response = "ERROR: could not find the file in the server"
                            self.request.sendall(response)
                    else:
                        #if received file name is broken, send error back to the client
                        response = "ERROR: missing file name"
                        self.request.sendall(response)
                elif(data.startswith('WRITE')):

                   filename = str(data.split(',')[1])

                   filesize = int(data.split(',')[2])
                   print "Receiving: " + str(filename) + " from %s" % thread_name

                   amount_received = 0
                   f1 = open(filename,'wb')

                   while(amount_received < filesize):
                       # try to receive the file, if connection closes suddenly, except block will run
                       try:
                           mess = self.request.recv(64)
                           if mess:
                               #print '\nServer Thread recevied %s' % mess
                               # write to the file each line received
                               f1.write(mess)
                               amount_received += len(mess)
                               print "AR: " + str(amount_received) + " size: " + str(filesize)
                           else:
                               f1.close()
                               break
                       except:
                           # close and delete the file if anything goes wrong.
                           f1.close()
                           os.remove(f1.name)
                           break

                   if(amount_received == filesize):
                       print "Done Receiving"
                       self.request.sendall("From Server: Recevied File: " +str(filename))
                elif(data == "BYE"):
                     # if bye is received, then break out of the while loop to end class
                    break;
                
        # at the end of class, decrease thread counter
        thread_counter -= 1
        print "" + str(thread_counter)
        if(thread_counter == 0):
            return


class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
    pass


if __name__ == "__main__":
    quit_server = False
    # Port 0 means to select an arbitrary unused port
    HOST, PORT = "localhost", 10000

    print "\nStart Threaded-Server on PORT %s " % PORT

    server = ThreadedTCPServer((HOST, PORT), ThreadedTCPRequestHandler)
    ip, port = server.server_address
    
    # Start a thread with the server -- that thread will then start one
    # more thread for each request
    server_thread = threading.Thread(target=server.serve_forever)
    
    # Terminate the server when the main thread terminates 
    # by setting daemon to True
    server_thread.daemon = True
    server_thread.start()
    print "Main Server using thread %s " % server_thread.name



    while True:
        # using while loop and raw_input to allow admin to quit the server
        command = raw_input("enter quit to exit server: \n")
        if(command == "QUIT"):
            if(thread_counter ==0):
                # if no connections the server closes by server.shutdown and quit()
                print 'Main server thread shutting down the server and terminating'
                server.shutdown()
                quit()
            else:
                print 'Waiting for threads to finish...'
                while(thread_counter !=0):
                    # if there are connection, the admin can still force quit the server
                    force_comment = raw_input("Type FORCEQUIT to type abruptly. \n")
                    if(force_comment == "FORCEQUIT"):
                        print 'Bye'
                        os._exit(0)
                    quit_server = True
                quit()

                    
                

