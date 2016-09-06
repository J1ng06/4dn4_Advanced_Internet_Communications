import socket
import sys

##define a Device object
class Device(object):
	name = None
	IP_address = None
	read_value = None
	target_value = None

##create a list to store all the devices
Devices  = []

##set-up first two devices and add to the list
mydevice = Device()
mydevice.name = "Thermostat-Main Room"
mydevice.IP_address = '177.68.25.17'
mydevice.read_value = 19
mydevice.target_value = 23	
Devices.append(mydevice)


mydevice = Device()
mydevice.name = "Thermostat-Living Room"
mydevice.IP_address = '177.68.25.18'
mydevice.read_value = 18
mydevice.target_value = 22
Devices.append(mydevice)


# Create a TCP/IP socket
sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
# Bind the socket to the port
server_address = ('172.17.176.100', 10000)
print >>sys.stderr, 'starting up on %s port %s' % server_address
sock.bind(server_address)
# Listen for incoming connections
sock.listen(1)

while True:
    # Wait for a connection
    print >>sys.stderr, 'waiting for a connection'
    connection, client_address = sock.accept()
    
    try:
        print >>sys.stderr, 'connection from', client_address

        
        while True:
        # Receive the data in large chunks and strip it
            data = connection.recv(1028)
            data = data.strip()
            print >>sys.stderr, 'received "%s"' % data
            
            if data:
##                set flags to determine whether duplication happens
                    
                dup_flag = False
                exist_flag = False
##                if statements to determine which command is sent
                if data.startswith('ADD'):
##                        split the parameter passed in
                        if (len(data.split(',')) == 3):
##                                loop through the list to find the device passed in to check if duplicate occures
                                for item in Devices:
                                        if(str(item.name) == str(data.split(',')[1])):
                                                dup_flag = True
                                                print >>sys.stderr, 'received "%s"' % dup_flag
##                                if not a duplicate, create a new device and add it to the list
                                if (dup_flag == False):    
                                        mydevice = Device()
                                        mydevice.name = data.split(',')[1]
                                        mydevice.IP_address = data.split(',')[2]
                                        Devices.append(mydevice)
                                        message = mydevice.name + " has been added."
                                        connection.sendall(message)
                                else:
##                                        return device already exists message
                                        message = "The Device already exists."
                                        connection.sendall(message)
                        else:
##                                return command format error
                                message = "Please make sure you type the right command."
                                connection.sendall(message)
                        
                elif data.startswith ("REMOVE"):
                    if (len(data.split(',')) ==2):
##                            loop through the list to find the device to be removed
                            for item in Devices:
                                if(str(item.name) == str(data.split(',')[1])):
##                                        if device is found, then remove the device from the list
                                        Devices.remove(item)
                                        message = data.split(',')[1] + " has been removed from the list of devices."
                                        connection.sendall(message)
                                        exist_flag = True
                            if (exist_flag == False):
##                                    return device not in list message
                                    message = "Device could not be found in the list"
                                    connection.sendall(message)
                        
                    else:
##                            return command format error
                        message = "Please make sure you type the right command."
                        connection.sendall(message)
                elif data.startswith ("READ"):
                        if (len(data.split(','))==2):
##                                loop through the list to find the device to be read from
                                    for item in Devices:
##                                            return the read-value from the device if found
                                        if (str(item.name) == str(data.split(',')[1])):
                                            message = str(item.name) + "'s read-value is " +  str(item.read_value) + ", the target-value is " + str(item.target_value)
                                            connection.sendall(message)
                                            exist_flag = True
                                    if (exist_flag == False):
##                                            return device not found message 
                                            message = "Device could not be found in the list"
                                            connection.sendall(message)                    
                        else:
##                                return command format error
                                message = "Please make sure you type the right command."
                                connection.sendall(message)
                                
                elif data.startswith ("WRITE"):
                        if (len(data.split(',') )==3):
##                                loop throught the list to fine the device to write to
                                    for item in Devices:
                                        if (str(item.name) == str(data.split(',')[1])):
##                                                write to the target value of the device found 
                                            item.target_value = data.split(',')[2]
                                            message = item.name + "'s new target_value is " +  item.target_value
                                            connection.sendall(message)
                                            exist_flag = True
                                    if (exist_flag == False):
##                                            return device not found message 
                                            message = "Device could not be found in the list"
                                            connection.sendall(message)

                        else:
##                                return command format error 
                                message = "Please make sure you type the right command."
                                connection.sendall(message)

                elif data.startswith("LIST"):
##                        self-defined command to list all the deivces inn the list
                        message = ""
##                        loop through all the devices in the list and print out all information
                        for i in range(0,len(Devices)):
                                print >>sys.stderr, 'message "%s"' % str(Devices[i].name)
                                message = message + str(Devices[i].name) + ", " + str(Devices[i].IP_address) + ", " + str(Devices[i].read_value) + ","+ str(Devices[i].target_value) + "\n"
                                print >>sys.stderr, 'message "%s"' % message
                        connection.sendall(message)
                    
                elif data.startswith ("QUIT"):
##                        send back connection closed message
                        message = "Connection ended on request."
                        connection.sendall(message)
                elif data.startswith("CONNECT"):
##                        send back connection made message
                        message = "Connection made!"
                        connection.sendall(message)
                else:
##                        send command unknown message
                        message = "Please make sure you type the right command."
                        connection.sendall(message)
            else:
##                    if data stops then close break and stop the program
                        print >>sys.stderr, 'no more data from', client_address
                        break
            
    finally:
# if any event to cause the while loop to stop then clean up the connection
        connection.close()
