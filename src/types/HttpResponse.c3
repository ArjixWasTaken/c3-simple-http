module http;

import std::io;
import std::net;
import std::collections;
import std::core::string;
import std::core::dstring;

struct HttpResponse {
    HttpStatus status;
    HttpHeaders headers;
    char[] body;
}

fn void! HttpResponse.write(HttpResponse* self, TcpSocket* socket) {
    @pool() {
        DString buffer;
        buffer.temp_init(64);

        buffer.appendf("HTTP/1.1 %d %s\r\n", self.status.code, self.status.message);

        Formatter formatter;

        if (self.body.len > 0) {
            if (!self.headers.is_initialized()) {
                self.headers.new_init();
            }

            StringList content_length;
            content_length.temp_init(1);
            content_length.push(string::tformat("%d", self.body.len)); // Leaked Allocation

            self.headers.set("Content-Length", content_length);
        }

        self.headers.@each(; String key, List(<String>) values)
        {
            foreach (value: values) {
                buffer.appendf("%s: %s\r\n", key, value);
            }
        };

        if (self.headers.len() > 0) {
            buffer.append_chars("\r\n");
        }

        socket.write(buffer.str_view())!;

        if (self.body.len > 0) {
            socket.write(self.body)!;
        }
    };
}

fn void HttpResponse.free(HttpResponse* self) {
    self.headers.free();
    free(self.body);
    //free(self);
}