module http;

import std::collections;

def HttpHeaders = HashMap(<String, List(<String>)>);

fn void! HttpHeaders.from_lines(HttpHeaders* self, List(<String>) lines) {
    foreach (line: lines) {
        line = line.trim();
        if (line == "") break;

        usz colon = line.index_of_char(':')!;

        String headerName = line[0..colon].trim();
        String headerValue = line[colon+1..line.len-1].trim();

        map::Entry(<String, List(<String>)>)*! entry = self.get_entry(headerName);
        if (try entry) {
            entry.value.push(headerValue);
        } else {
            List(<String>) values;
            values.new_init(2);
            values.push(headerValue);
            self.set(headerName, values);
        }
    }
}
