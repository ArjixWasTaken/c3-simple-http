module http;

import std::io;
import std::thread;

import std::net;
import std::net::tcp;

const uint BACKLOG = 10000;

fn int process(void* arg) {
    TcpSocket* socket = arg;
    defer socket.close()!!;

    HttpRequest req;
    req.read(socket)!!;

    HttpResponse res;
    res.status = HttpStatus.OK;
    res.body = string::new_format("You made a %s request to %s\n", req.method, req.uri);

    res.write(socket)!!;

    return 0;
}

fn int main(String[] args)
{
    String host = "127.0.0.1";
    uint port = 8080;

    TcpServerSocket! server = tcp::listen(host, port, BACKLOG, net::SocketOption.REUSEADDR, .ip_protocol=net::IpProtocol.IPV4);

    if (catch err = server) {
        io::printfn("failed to bind <%s:%d> with failure: %s", host, port, err);
        return 1;
    } else {
        io::printfn("listening on <%s:%d>", host, port);
    }

    while (try TcpSocket socket = tcp::accept(&server)) {
        thread::Thread thread;

        thread.create(&process, @clone(socket))!!;
        thread.detach()!!;
    }

    return 0;
}
