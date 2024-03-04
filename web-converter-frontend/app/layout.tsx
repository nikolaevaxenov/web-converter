import { Providers } from "./providers";
import Head from "./head";
import "@/styles/globals.css";

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <Head />

      <body>
        <Providers>
          <div className="wrapper">
            <main className="wrapper__content">{children}</main>
          </div>
        </Providers>
      </body>
    </html>
  );
}
