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
List_of_Peers = []
HOST, PORT = "localhost", 10002


class Peer(object):
    IP_address = None
    Port = None

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
        elif (fileExtension == '.pdf'):
            new_file.type = "PDF"
            List_of_files.append(new_file)
    return List_of_files

def send_using_new_socket(IP,port,message):
    server_address = (IP,int(port))

    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.connect(server_address)
        sock.sendall(message)
    except:
        pass
        


class ThreadedTCPRequestHandler(SocketServer.BaseRequestHandler):

    def handle(self):
        global thread_counter
        thread_counter  += 1
        
        cur_thread = threading.current_thread()  # identify current thread
        thread_name = cur_thread.name   # get thread-number in python     

        data = self.request.recv(1024)
        data = data.strip()
        
        
        if(data != ''):
            if(data.startswith('LISTR')):
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
            elif(data.startswith("DISCOV_Result")):
                #print "disocover result"
                new_peer = True
                new_IP_address = data.split(',')[1]
                new_port_number = int(data.split(',')[2])

                #loop to check for duplicate peer
                for peer in List_of_Peers:
                    if(peer.IP_address == new_IP_address and peer.Port == new_port_number):
                        new_peer = False
                        
                #if new peer indeed, then define new Peer object 
                if(new_peer == True):
                    a_new_peer = Peer()
                    a_new_peer.IP_address = new_IP_address
                    a_new_peer.Port = new_port_number
                    #add new peer to the list
                    List_of_Peers.append(a_new_peer)
                    #give feedback
                    print "IP:" + str(a_new_peer.IP_address) +  ",Port:" + str(a_new_peer.Port) + " has been added to the list."
                else:
                    print "IP:" + str(new_IP_address) +  ",Port:" + str(new_port_number) + " is already in the list."
                print "Enter your Command:"
                                
            elif(data.startswith("DISCOVER")):
                #print 'received discover'
                TTL = int(data.split(',')[1])
                main_IP = data.split(',')[2]
                main_port = int((data.split(',')[3]))

                #check if packet is still valid
                if(TTL > 0):
                    TTL -= 1
                    #send back alive message
                    response = "DISCOV_Result," + HOST + "," + str(PORT)
                    data = data.split(',')[0] + ","  + str(TTL) + "," + main_IP + "," + str(main_port)
                    send_using_new_socket(main_IP, main_port, response)
                    #forward discover request
                    for peer in List_of_Peers:
                        if(peer.IP_address != main_IP or peer.Port != main_port):
                            send_using_new_socket(peer.IP_address,peer.Port, data)



            elif(data.startswith("SEARCH")):
                #print 'received search'
                TTL = int(data.split(',')[2])
                filename = data.split(',')[1]
                main_IP = data.split(',')[3]
                main_port = data.split(',')[4]
                List_of_files = getList()
                    

                #check if packet is still valid
                if(TTL > 0):
                    TTL = TTL - 1
                    data = data.split(',')[0] + "," + filename + "," + str(TTL) + "," + main_IP + "," + main_port
                    
                    for files in List_of_files:
                        if files.name == filename:
                            #file found
                            response =  "SEAR_Result" + "," +  HOST + "," + str(PORT)
                            send_using_new_socket(main_IP,main_port, response)
                            break
                    #forward search request
                    for peer in List_of_Peers:
                        if(peer.IP_address != main_IP or peer.Port != main_port):
                            send_using_new_socket(peer.IP_address,peer.Port, data)
                    

            elif(data.startswith("SEAR_Result")):
                #file found message
                #print IP and port contained in message
                print "File has been found at IP_Address: " + data.split(',')[1] +" Port: " + data.split(',')[2] + "\n"
                print "Enter your Command:"
            elif(data.startswith("GET")):
                #get file list
                List_of_files=getList()
                if(len(data.split(',')) == 4):
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
                            print "Sending " + str(filename) + " to %s" %thread_name

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
            
        # at the end of class, decrease thread counter
        thread_counter -= 1
        if(thread_counter == 0):
            return
        
        


class ThreadedTCPServer(SocketServer.ThreadingMixIn, SocketServer.TCPServer):
    pass


if __name__ == "__main__":
    quit_server = False
    # Port 0 means to select an arbitrary unused port

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

    
    # Create a TCP/IP socket
    sock = None
    server_address = ''

    # Add 1 known peer to begin with
    known_peer = Peer()
    known_peer.IP_address = 'localhost'
    known_peer.Port = 10003
    List_of_Peers.append(known_peer)


    # Get the list of files in the current directory for later use
    List_of_files = getList()



    while True:
        # using while loop and raw_input to allow admin to quit the server
        command = raw_input("Enter your Command: \n")
        if(command == "QUIT"):
            if(thread_counter ==0):
                # if no connections the server closes by server.shutdown and quit()
                print 'Main server thread shutting down the server and terminating'
                server.shutdown()
                quit()
            else:
                print 'Waiting for threads to finish... \n'
                while(thread_counter !=0):
                    # if there are connection, the admin can still force quit the server
                    force_comment = raw_input("Type FORCEQUIT to quit abruptly. \n")
                    if(force_comment == "FORCEQUIT"):
                        print 'Bye'
                        os._exit(0)
                    quit_server = True
                quit()
        elif(command == "LISTL"):
            #get local files
            feedback = ""
            List_of_files=getList()
            for files in List_of_files:
                # prepare the response
                feedback = feedback + str(files.type)+ "\t " + str(files.name) + "\t size: " + str(files.size) + " bytes\n"
            if(feedback == ""):
                # send the response using request.sendall
                print "There is no files in the directory"
            else:
                print feedback

        elif(command.startswith("LISTR")):
            if(len(command.split(',')) == 3):
                #inputs are okay
                server_address = (command.split(',')[1],int((command.split(',')[2])))
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                #send message and listen for response
                try:
                    sock.connect(server_address)
                    sock.sendall("LISTR")
                
                    data = sock.recv(1024)
                    #print response to the screen if there are any
                    if data:
                        print data
                except:
                    print "Could not connect to the IP and Port provided"
                
            else:
                print "please provide the ip-address and port number seperated by comma. \n"
        elif(command.startswith("SEARCH")):
            if(len(command.split(',')) == 3):
                #inputs are okay
                for peer in List_of_Peers:
                    try:
                        #define sockets
                        server_address = (peer.IP_address,peer.Port)
                        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                        sock.connect(server_address)
                        #append this peer's IP and Port then send the message
                        sock.sendall(command + "," + HOST + "," + str(PORT))
                        sock.close()
                        
                    except:
                        print "Could not connect to " + peer.IP_address + "."
                    
            else:
                print "please provide the file name and time to live hop number seperated by comma. \n"
        elif(command.startswith("DISCOVER")):
            if(len(command.split(',')) == 2):
                for peer in List_of_Peers:
                    try:
                        #define sockets
                        server_address = (peer.IP_address,peer.Port)
                        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                        sock.connect(server_address)
                        #append this peer's IP and Port then send the message
                        sock.sendall(command + "," + HOST + "," + str(PORT))
                        sock.close()
                    except:
                        print "Could not connect to " + str(peer.IP_address)
            else:
                print "please provide the time to live hop number seperated by comma. \n"
        elif(command.startswith("GET")):
            if(len(command.split(',')) == 4):
                #inputs are okay
                connected = False
                server_address = (command.split(',')[2],int((command.split(',')[3])))
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                try:
                    sock.connect(server_address)
                    connected = True
                except:
                    print "Could not connect to the server address provided."
                    connected = False

                if(connected):
                    sock.sendall(command)
                    data = sock.recv(64)
                    if(data.startswith("ERROR:")):
                        print >>sys.stderr, '"%s"' %data
                    else:
                        # first receive is the file size of the data from the peer end
                        filesize = int(data)
                        amount_received = 0
                        f1 = open(command.split(',')[1],'wb')
                        # receive until amount received is greater or equal to file size
                        while amount_received < filesize:
                            try:
                                data = sock.recv(128)
                                f1.write(data)
                                amount_received = len(data) + amount_received
                            except:
                                f1.close()
                                os.remove(f1.name)
                                sock = None
                                break
                        if(amount_received == filesize):
                            print "File Received"
                            f1.close()

                    
            else:
                print "please provide the file name, ip-address and port number seperated by comma. \n"
        elif(command.startswith("RESET")):
            # reset list and add back the hardcoded peer
            List_of_Peers = []
            known_peer = Peer()
            known_peer.IP_address = 'localhost'
            known_peer.Port = 10003
            List_of_Peers.append(known_peer)
            print "List of Peers has been reseted"
        #command not recognized
        else:
            print "command entered is not recognized"
        
                

