#include "fig.h"
#include "scat.h"

#include <filesystem>
#include <fstream>
#include <iostream>

void find_config (std::filesystem::path path, Config* conf) {
    std::filesystem::path check_path = path / ".scad-format";
    if (std::filesystem::exists (check_path)) {
        conf->parse (check_path.string ());
        return;
    }
    if (path.compare ("/") == 0) {
        std::cerr << "Could not find .scad-format file. Using default settings." << std::endl;
        return;
    }
    find_config (path.parent_path (), conf);
}

int main (int argc, char** argv) {
    Config conf;
    conf.set ("comma padding", 0);
    conf.set ("function padding", 1);
    conf.set ("indent spaces", 4);
    conf.set ("indent type", "tabs");
    conf.set ("line after function", 0);
    conf.set ("line after module", 0);
    conf.set ("one function per line", false);
    conf.set ("operator padding", 0);
    conf.set ("pad before angular", 0);
    conf.set ("pad before comment", 0);
    conf.set ("pad before brace", 0);
    conf.set ("pad before bracket", 0);
    conf.set ("pad comment start", 0);
    conf.set ("pad inside angular", 0);
    conf.set ("pad inside bracket", 0);
    conf.set ("pad inside square", 0);
    conf.set ("tab before comment", false);
    conf.set ("tab width", 4);
    find_config (std::filesystem::current_path (), &conf);
    std::stringstream ss;
    for (int i = 1; i < argc; ++i) {
        try {
            format (argv[i], conf, &ss);
            std::ofstream of (argv[i]);
            if (!of.is_open ()) throw std::runtime_error ("Could not write to file");
            of << ss.rdbuf ();
            of.close ();
        } catch (std::exception& e) {
            std::cerr << "Could not format " << argv[i] << ": " << e.what () << std::endl;
        }
    }
    return 0;
}
