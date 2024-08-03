module http;

import std::io;
import std::net;
import std::collections;

struct Request {
    HttpVerb method;
    String uri;
    HttpHeaders headers;
}

fault RequestError {
    NO_DATA,
    UNIMPLEMENTED
}

fn void! Request.read(Request* self, TcpSocket* socket) {
    List(<char>) bytes;
    bytes.new_init();

    char[1024] buffer;
    while (try usz bytes_read = socket.read(&buffer)) {
        io::printf("Bytes read: %s\n", bytes_read);

        bytes.add_array(buffer[:bytes_read]);
        io::printf("Bytes length: %s\n\n", bytes.size);

        if (bytes_read < 1024) break;
    }

    foreach (b : bytes)
    {
       io::printn(b);
    }

    return RequestError.UNIMPLEMENTED?;
}
