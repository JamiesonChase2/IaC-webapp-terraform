const http = require("http");

const port = Number.parseInt(process.env.PORT ?? "8080", 10);

http
  .createServer((req, res) => {
    const url = req.url ?? "/";

    if (url === "/healthz") {
      res.writeHead(200, { "content-type": "application/json" });
      return res.end(JSON.stringify({ status: "ok" }));
    }

    if (url === "/fail") {
      res.writeHead(500, { "content-type": "application/json" });
      return res.end(JSON.stringify({ status: "error" }));
    }

    res.writeHead(200, { "content-type": "text/plain; charset=utf-8" });
    res.end("Hello. Try /healthz and /fail\n");
  })
  .listen(port, "0.0.0.0");

