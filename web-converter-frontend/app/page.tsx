import ConverterComponent from "@/components/ConverterComponent";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";

export default function Home() {
  return (
    <div className="main">
      <div className="border-4 rounded-md m-5 p-5">
        <Tabs defaultValue="algebra" className="w-auto">
          <TabsList className="grid w-full grid-cols-2 mb-5">
            <TabsTrigger value="algebra">Алгебра</TabsTrigger>
            <TabsTrigger value="tuple">Кортеж</TabsTrigger>
          </TabsList>
          <TabsContent value="algebra">
            <ConverterComponent />
          </TabsContent>
          <TabsContent value="tuple">
            <ConverterComponent />
          </TabsContent>
        </Tabs>
      </div>
    </div>
  );
}
