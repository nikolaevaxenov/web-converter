"use client";

import { ReactNode } from "react";
import { QueryClient, QueryClientProvider } from "react-query";

type ProviderProps = {
  children?: ReactNode;
};

export function Providers({ children }: ProviderProps) {
  const queryClient = new QueryClient();

  return (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
}
