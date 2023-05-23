# Networking Crash Course

## Open System Intercommunication Model (OSI)

Why do we need a communication model?
- Compatibility - e.g. cross-platform compilation
- Network Equipment Management
- Decoupled Innovation

## The 7 Layers of the OSI Model
```
L7 - Application    HTTP/FTP/GRPC
L6 - Presentation   Encoding, Serialization
L5 - Session        Connection Establishment, TLS
L4 - Transport      UDP/TCP
L3 - Network        IP
L2 - Data Link      Frames, MAC Address
L1 - Physical       Electric signals, fiber, radio
```

## Communication Protocols

Generally, these have the following properties

- Data Format
  - Text based (plaintext, JSON, XML)
  - Binary (protobuf, RESP, h2, h3)
- Transfer mode
  - Message based (UDP, HTTP) - "has a start and end"
  - Stream based (TCP, WebRTC)
- Addressing system
  - DNS, IP, MAC
- Directionality
  - Bidirectional (TCP)
  - Unidirectional (HTTP)
  - Full/Half duplex - no two devices can send at the same time
- State
  - Stateful (TCP, gRPC, apache thrift)
  - Stateless (UDP, HTTP)
- Routing
  - Proxies, Gateways
- Flow & Congestion control
  - TCP (Flow & Congestion)
  - UDP (No control)
- Error Management
  - Error code
  - Retries and timeouts

## The Internet Protocol (IP)

References:
- [Original IP RFC](https://www.rfc-editor.org/rfc/rfc791)

Vocabulary
- Header
- Frame
- Maximum Transmission Unit (MTU)

IPv4 is made up of 4 bytes (a.b.c.d/N) where a,b,c,d are
integers and N tells you how many of the bits describe the
`network` and the remaining bits are used to describe the
`host` (32 - N).

e.g. `192.168.254.0/24 ` (this is `CIDR` Notation)

This says that the first 24 bits (3 bytes). This implies
that we can have 2^24 networks and each network has 2^8
hosts. This is also known as a `subnet`

In this case, the subnet has a `mask` defined as
`255.255.255.0` and we use this to determine if an IP is
in the same subnet.

Every subnet will end up having a `default gateway` that
is responsible for routing traffic in and out of the
subnet.

This subnet mask is mainly used whether to check if a
"message" is being sent from an IP address within the
subnet. In order to make it more obvious, we can visualize
it in terms of bits (you might have also heard about a
`bit mask`)

```
255.        255.        255.        0
11111111    11111111    11111111    00000000
```

If we were to naively spell out the application of a subnet mask in Python, it would looks something like this:

```python
ip_address = "192.168.254.1"
subnet_mask = "255.255.255.0"

octets = [ int(octet) for octet in ip_address.split(".") ]
# [192, 168, 254, 1]
octets = [ f"{bin(octet)[2:]:>08}" for octet in octets ]
# ['11000000', '10101000', '11111110', '00000001']

ip_address = int(f"0b{'_'.join(octets)}", 2)
# bin(ip_address) = '0b11000000101010001111111000000001'

octets = [ int(octet) for octet in subnet_mask.split(".") ]
# [255, 255, 255, 0]
octets = [ f"{bin(octet)[2:]:>08}" for octet in octets ]
# ['11111111', '11111111', '11111111', '00000000']

subnet_mask = int(f"0b{'_'.join(octets)}", 2)
# bin(subnet_mask) = '0b11111111111111111111111100000000'

# bin(subnet_mask)              = '0b11111111111111111111111100000000'
# bin(ip_address)               = '0b11000000101010001111111000000001'
# bin(subnet_mask & ip_address) = '0b11000000101010001111111000000000'
```

### IP Packets
- The IP Packet has headers and data sections
- IP Packet header is 20 bytes (can go up to 60 bytes)
- Data section can go up to 65536 bytes (2^16)
- Realistically, the standard Maximum Transmission Unit (MTU) on ethernet is 1500 bytes

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|Version|  IHL  |Type of Service|          Total Length         |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|         Identification        |Flags|      Fragment Offset    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Time to Live |    Protocol   |         Header Checksum       |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                       Source Address                          |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Destination Address                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Options                    |    Padding    |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

- **Version** [4 bits] - IPv4 or IPv6
- **Internet Header Length (IHL)** [4 bits]- How many rows in the header (default 5 "rows" up to options)
- **Total Length** [16 bits] - Total length of the headers (enough to describe headers + data)
- **Fragmentation** - If the packets are too large, you might consider fragmentation. `QUIC` disables fragmentation because it's hard to deal with fragmentation correctly. **Flags** tells us if we want fragmentation or not.
- **Time to Live (TTL)** [8 bits] - How many hops can this packet survive? IP is stateless, but we also don't want packets to be floating around the internet forever. Every router and host that sees an IP packet is responsible for decrementing TTL. When TTL hits 0, they are responsible for sending a message back to the source. 
- **Protocol** [8 bits] - describes whether this is ICMP, TCP, UDP, etc. If you only accept certain protocols, you can decide to not accept an IP packet without reading the data - see full list from [wikipedia](https://en.wikipedia.org/wiki/List_of_IP_protocol_numbers)
- **Explicit Congestion Notification (ECN)** [2 bits] - when packets start to drop, a router becomes congested. All routers must have some memory (buffer) dedicated handling accepted packets that have not been processed yet. Without ECN, routers would just drop packets and not say anything - however this causes the client to wait for some arbitrary amount of time before deciding that the router is congested.

### Internet Control Message Protocol (ICMP)
- Designed for informational messages
  - Host unreachable, port unreachable, fragmentation needed
  - Packet expired (infinite loop in routers)
- Uses IP directly
- `ping` and `traceroute` use it
- Doesn't require listeners or ports to be opened

At a high-level, `traceroute` sets a tiny TTL and deliberately lets the TTL hit 0, then it increments it until it makes it to every path - however some routers disable ICMP
### TraceRoute
- Identify the path that IP Packet takes
- Clever use of TTL
- Not always correct due to path changes and ICMP blocking

## User Datagram Protocol (UDP)

- Layer 4 protocol
- Ability to address processes in a host using ports
- Simple protocol to send and receive data
- Prior communication not required
- Stateless no knowledge is stoerd on the host
- 8 byte header Datagram

Pros
- Simple protocol
- Header size is small so datagrams are small
- uses less bandwidth
- stateless
- consumes less memory (no state stored in the server/client)
- low latency - no handshake, order, retransmission or guaranteed delivery

Cons
- No acknowledgement
- No guaranteed delivery
- connection-less (anyone can send data without prior knowledge)
- no flow control
- no congestion control
- no ordered packets
- security - can be easily spoofed

## Transmission Control Protocol (TCP)

- Layer 4 Protocol
- Ability to address processes in a host using ports
- Controls transmission unlike UDP
- Connection
- requires handshake
- 20 bytes headers segment (can go to 60)
- Stateful

### TCP Connection

- This connection is layer 5 (session)
- Connection is an agreement between client and server
- must create a connection to send data
- connection is identified by 4 properties
  - Source IP <> Source Port
  - Destination IP <> Destination Port
- Can't send data outside of a connection
- sometimes call socket or file descriptor
- Requires a 3-way TCP handshake
- segments are sequenced and ordered
- segments are acknowledged
- lost segments are retransmitted

#### Multiplexing and Demultiplexing

- IP target hosts only
- hosts run many apps each with different requirements
- ports now identify the app or process
- sender multiplexes all its apps into TCP connections
- receiver demultiplex TCP segments to each app based on connection pairs

#### Connection Establishment

- `app_1` on 10.0.0.1 wants to send data to `app_2` on 10.0.0.2
- `app_1` sends SYN to `app_2` to synchronize sequence numbers
- `app_2` sends SYN/ACK to synchronize sequence numbers
- `app_1` ACKs, `app_2` SYN

#### Sending Data

- `app_1` sends `seq_1` to `app_2`
- `app_2` ACKs the message

note: `app_1` can continue sending before receiving an
ACK. Additionally, `app_2` can ACK multiple sequences at a
time.

Re-transmission occurs when the sender notices that the
ACK doesn't line up with their sequence.

#### Closing Connection

Four way handshake
- `app_1` wants to close the connection
- `app_1` sends FIN, `app_2` ACK
- `app_2` sends FIN, `app_1` ACK

### TCP Segment

https://www.ietf.org/rfc/rfc793.txt

- TCP segments slides into an IP packet as "data"
- header is 20 bytes
- ports are 16 bits (2^16)
- Sequences, Acknowledgement, Flow control, etc.
- Segment size depends on the maximum transmission units (MTU) of the network
- Usually 512 bytes can go up to 1460
- Default MTU in the internet is 1500 (results in MSS 1460)
- Jumbo frames MTU goes to 9000 or more
- MSS can be larger in jumbo frames cases

## Transport Layer Security (TLS)

TLS usually sites at L5 (session). Typically, we're
talking about TLS through HTTP.

TCP serves a number of purposes
- encrypt with symmetric key algorithms
- exchange the symmetric key
- key exchange uses asymmetric key (PKI)
- authenticate the server
- extensions (SNI, preshared, 0RTT)

- Vanilla HTTP
- HTTPS
- TLS 1.2 Handshake (two round trips)
- Diffie Hellman
- TLS 1.3 (one round trip and can be zero)

# Backend Engineering Patterns
## Synchronous vs. Asynchronous Workloads

- Asynchronous Programming (promises/futures)
- Asynchronous Backend Processing
- Asynchronous Commits in Postgres
  - Write Ahead Log - WAL
    - WAL is usually small enough to trust with commit
    - Synchronous commit will write WAL to disk
    - Asynchrononous commit will  
  - Page
- Asynchronous IO in Linux (epoll, io_uring)
- Asynchronous Replication
- Asynchronous OS fsync (fs cache)

## The "Push" Model

If you want to get results as soon as possible, the push
model enables this behavior.

The push model looks like this:
- Client connects to a server
- Server sends data to the client
- client doesn't have to make a request (listens)

However, push comes with it's own set of disadvantages. 

- Real time

- Client must be online and listening for push
- Clients might not be able to handle
- Protocol must be bidirectional
- Polling is preferred for light clients

Example:
- RabbitMQ

## Short Polling

Pros:
- Simple
- Good for long running requests
- Client can disconnect

Cons:
- Too chatty
- Network bandwidth
- Wasted backend resources

## Long Polling

1. Client sends a request
2. Server responds with a handle (job id)
3. Client waits as long as they want for the response
4. Server completes job and responds if client is waiting,
otherwise holds onto the completed response until the
client makes a request.

Pros
- Less chatty and backend firendly
- Client can still disconnect

Cons
- Not real time

## Server Sent Events

- A response has a start and end
- Client sends a request
- Server sends logical events as part of response
- Server never writes the end of the response

Pros
- Real time
- Compatible with Request/Response model

Cons
- Clients must be online
- Clients might not be able to handle
- Polling is preferred for light clients
- HTTP/1.1 problem (6 connections)

## Publish Subscribe

A model for managing more complex mesh of communications.

A client can publish to the server and move on. The other
clients can consume the pieces that were just published.

Request/Response

Pros
- Elegant and simple
- Scalable

Cons
- Bad for multiple receivers
- High Coupling
- Client/Server have to be running
- Chaining, circuit breaking

Pub/Sub

Pros
- Scales with multiple receivers
- Great for microservices
- Loose coupling
- Works while client is offline

Cons
- Message delivery issues (two generals problem)
- Complexity
- Network saturation (polling, etc.)

Multiplexing vs. Demultiplexing

HTTP/1.1
- 6 separate connections
HTTP/2
- multiplex all connections onto a single pipeline

Connection Pooling

Stateless vs. Stateful

## Sidecar

Run all communication through a proxy so that
communication protocol is no longer stuck to the main
client/server.

Pros
- Language agnostic
- Protocol upgrades
- Security
- Tracing and Monitoring
- Service Discovery
- Caching

Cons
- Complexity
- Latency

# References

- https://root-servers.org
- https://www.cloudflare.com/en-ca/learning/cdn/glossary/anycast-network/
- encryption - https://www.youtube.com/watch?v=_zyKvPvh808
