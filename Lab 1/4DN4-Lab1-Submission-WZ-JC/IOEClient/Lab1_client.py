import socket
import sys

# Create a TCP/IP socket


# Connect the socket to the port where the server is listening

##define server address string
server_address = ''




# Send data
while True:
##    if the server address is empty then prompt the user to enter the server address
    if(server_address == ''):
        message = raw_input('Enter the CONNECT,IP Address,Port Number to establish connection.\n')
    else:
##    if there is a server address stored already, then prompt the user to enter the command
        message = raw_input('Enter your command.\n')

    if message.startswith("CONNECT"):
        if (len(message.split(','))== 3):
##            if command is connect, then try to make connect to the server
            try:
                server_address = (message.split(',')[1],int((message.split(',')[2])))
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.connect(server_address)
                sock.sendall(message)
                amount_received = 0

##                wait to receive the connection messages from the server
                data = sock.recv(1028)
                amount_received += len(data)
                print >>sys.stderr, 'received "%s"' % data
                sock.close()
            except:
##                if anything went wrong, then return message to re-enter address
                print >>sys.stderr, "Please make sure the IP and port address are enterd correctly"
        else:
            print >>sys.stderr, "Please make sure you enter the IP and port address"
    elif message.startswith("QUIT"):
##        if command is Quit, then send command and wait for respond message from server
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect(server_address)
        sock.sendall(message)
        print >>sys.stderr, 'sending "%s"' % message
        amount_received = 0
        
        data = sock.recv(1028)
        amount_received += len(data)
        print >>sys.stderr, 'received "%s"' % data
        sock.close()
##        empty the server address
        server_address = ''
    else:
        if server_address == "":
            print >>sys.stderr, 'Please enter the IP and port number.'
        else:
            try:
                sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                sock.connect(server_address)
                sock.sendall(message)
            except:
                print >>sys.stderr, 'IP address or port number are wrong'
                break
            finally:
                print >>sys.stderr, 'sending "%s"' % message
                amount_received = 0
                #amount_expected = len(message)
                data = sock.recv(1028)
                amount_received += len(data)
                print >>sys.stderr, 'received "%s"' % data
                sock.close()





        
##    if message.startswith("CONNECT"):
##        if (len(message.split(' '))== 3):
##            try:
##                sock.close()
##                sock.connect(message.split(' ')[1],int((message.split(' ')[2])))
##            except:
##                print >>sys.stderr, "Please make sure the IP and port address are enterd correctly"
##                break
##        else:
##            print >>sys.stderr, "Please make sure you enter the IP and port address"
##    else:
##        if(sock is not None):
##            sock.sendall(message)

        
    # Look for the response
    #amount_received = 0
    #amount_expected = len(message)

    #while amount_received < amount_expected:
 

