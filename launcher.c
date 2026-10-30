/* Minimal standalone CLI carrier for fogtape's unmodified NodeMobile runtime. */
extern int node_start(int argc, char *argv[]);
int main(int argc, char *argv[]) {
    return node_start(argc, argv);
}
