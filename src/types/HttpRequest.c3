module http;

import std::io;
import std::net;
import std::collections;
import std::core::string;

const ulong MAX_READ_SIZE = /* 5 MiB */ 1024 * 1024 * 5;

struct HttpRequest {
    HttpVerb method;
    String uri;
    HttpHeaders headers;
    char[] body;
}

fault HttpRequestError {
    NO_DATA,
    REQUEST_TOO_LARGE,
    UNIMPLEMENTED
}

fn void! HttpRequest.read(HttpRequest* self, TcpSocket* socket) {
    List(<char>) bytes;
    bytes.new_init(256);

    char[1024] buffer;
    while (try usz bytes_read = socket.read(&buffer)) {
        bytes.add_array(buffer[:bytes_read]);

        if (bytes.size >= MAX_READ_SIZE) return HttpRequestError.REQUEST_TOO_LARGE?;
        if (bytes_read < 1024) break;
    }

    if (bytes.size == 0) return HttpRequestError.NO_DATA?;

    List(<char>) header;
    header.new_init(256);

    usz i = 0;
    for (; i < bytes.size; i++) {
        if (
            bytes[i] == '\r' && bytes[i + 1] == '\n' &&
            bytes[i + 2] == '\r' && bytes[i + 3] == '\n'
        ) {
            i += 4;
            break;
        }

        header.push(bytes[i]);
    }
    header.push('\0');

    char[] body = bytes.entries[i..bytes.size];

    List(<String>) header_lines;
    header_lines.new_init_with_array(((ZString)header.entries).str_view().split("\r\n"));

    String status_line = header_lines.pop_first()!;
    io::printfn("status_line: %s", status_line);

    return HttpRequestError.UNIMPLEMENTED?;
}
