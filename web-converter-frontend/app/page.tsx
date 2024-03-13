import ConverterComponent from "@/components/ConverterComponent";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

export default function Home() {
  return (
    <div className="m-5 rounded-md border-4 p-5">
      <Tabs defaultValue="algebra" className="w-auto">
        <TabsList className="mb-5 grid w-full grid-cols-2">
          <TabsTrigger value="algebra">Алгебра</TabsTrigger>
          <TabsTrigger value="tuple">Кортеж</TabsTrigger>
        </TabsList>
        <TabsContent value="algebra">
          <ConverterComponent converterType="algebra" />
        </TabsContent>
        <TabsContent value="tuple">
          <ConverterComponent converterType="tuple" />
        </TabsContent>
      </Tabs>
      <div className="flex flex-row justify-center gap-3 mt-5">
        <a
          href="https://github.com/nikolaevaxenov"
          target="_blank"
          className="text-sm font-semibold text-slate-800 underline decoration-sky-300 decoration-2 underline-offset-2 hover:text-slate-600 hover:decoration-wavy"
        >
          Nikolaev-Axenov, 2024
        </a>
      </div>
    </div>
  );
}
