"use client";

import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { Separator } from "@/components/ui/separator";
import {
  Check,
  Pen,
  Plus,
  RefreshCcw,
  Save,
  SendHorizontal,
  Trash2,
  X,
} from "lucide-react";
import { useState } from "react";

export default function AlgebraConverterComponent() {
  const [toggleResultTable, setToggleResultTable] = useState(true);

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-col lg:flex-row gap-5">
        <div className="flex flex-auto flex-col gap-5">
          <div className="flex flex-col lg:flex-row items-center gap-1.5">
            <Label htmlFor="group">Группа:</Label>
            <Input id="group" type="text" />

            <Label htmlFor="last-name">Фамилия:</Label>
            <Input id="last-name" type="text" />

            <Label htmlFor="identification-number">Номер запроса:</Label>
            <Input id="identification-number" type="text" />
            <Select>
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Запрос" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="light">N00D_New_Shchukin</SelectItem>
                <SelectItem value="dark">N035_New_Shchukin</SelectItem>
                <SelectItem value="system">X001_EXP_Shchu</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div className="grid lg:grid-cols-2 gap-x-5 gap-y-1.5">
            <div className="flex items-center order-1 lg:order-none">
              <Label htmlFor="description">Описание запроса:</Label>
            </div>
            <div className="flex items-center justify-between order-3 lg:order-none">
              <Label htmlFor="variable-types">Типы переменных:</Label>
              <Popover>
                <PopoverTrigger asChild>
                  <Button variant="outline" title="Добавить переменную">
                    <Plus />
                  </Button>
                </PopoverTrigger>
                <PopoverContent className="w-80">
                  <div className="flex flex-col gap-1.5">
                    <Button variant="outline">
                      <Plus className="mr-1" /> queryalgb
                    </Button>
                    <Button variant="outline">
                      <Plus className="mr-1" /> querytupl
                    </Button>
                    <Button variant="outline">
                      <Plus className="mr-1" /> выполнение
                    </Button>
                    <Button variant="outline">
                      <Plus className="mr-1" /> группы
                    </Button>
                    <Button variant="outline">
                      <Plus className="mr-1" /> календарныйплан
                    </Button>
                    <Button variant="outline">
                      <Plus className="mr-1" /> курслекций
                    </Button>
                    <Button variant="outline">
                      <Plus className="mr-1" /> регби
                    </Button>
                    <Button variant="outline">
                      <Plus className="mr-1" /> студенты
                    </Button>
                    <Button variant="outline">
                      <Plus className="mr-1" /> худгимнастика
                    </Button>
                  </div>
                </PopoverContent>
              </Popover>
            </div>
            <div className="order-2 lg:order-none">
              <Textarea className="resize-none" id="description" />
            </div>
            <div className="order-4 lg:order-none">
              <Textarea className="resize-none" id="variable-types" />
            </div>
          </div>
          <div className="flex flex-col grow gap-1.5">
            <Label htmlFor="target-list">Целевой список:</Label>
            <Input id="target-list" type="text" />
          </div>
          <div className="flex flex-col lg:flex-row gap-5">
            <Textarea className="resize-none" id="input-query" />
            <Textarea className="resize-none" id="output-query" />
          </div>
        </div>
        <div className="flex flex-col gap-3">
          <Button>
            <Check className="mr-2" /> Принять запрос
          </Button>
          <Button variant="secondary">
            <Save className="mr-2" /> Сохранить запрос
          </Button>
          <Button variant="secondary">
            <Pen className="mr-2" /> Изменить запрос
          </Button>
          <Button variant="destructive">
            <Trash2 className="mr-2" /> Удалить запрос
          </Button>
          <Separator />
          <Button>
            <Plus className="mr-2" /> Генерировать SQL
          </Button>
          <div className="flex flex-row gap-1.5">
            {toggleResultTable ? (
              <>
                <Button className="flex grow" variant="secondary">
                  <RefreshCcw className="mr-2" /> Обновить
                </Button>
                <Button
                  variant="destructive"
                  onClick={() => setToggleResultTable(false)}
                >
                  <X />
                </Button>
              </>
            ) : (
              <Button
                className="flex grow"
                onClick={() => setToggleResultTable(true)}
              >
                <SendHorizontal className="mr-2" /> Выполнить SQL
              </Button>
            )}
          </div>
          <Separator />
          <Button variant="secondary">
            <Save className="mr-2" /> Создать View
          </Button>
        </div>
      </div>
      <div className="flex flex-row" id="result-table">
        {toggleResultTable ? (
          <Table className="border">
            <TableHeader>
              <TableRow>
                <TableHead>Нз</TableHead>
                <TableHead>Фио</TableHead>
                <TableHead>П</TableHead>
                <TableHead>Возр</TableHead>
                <TableHead>Гр</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow>
                <TableCell>ст401.1</TableCell>
                <TableCell>Крымов В.А.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>20</TableCell>
                <TableCell>Б13-401</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст401.2</TableCell>
                <TableCell>Хромов В.А.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>21</TableCell>
                <TableCell>Б13-401</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст401.3</TableCell>
                <TableCell>Дронов В.С.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>22</TableCell>
                <TableCell>Б13-401</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст401.4</TableCell>
                <TableCell>Крутов М.А.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>22</TableCell>
                <TableCell>Б13-401</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст401.5</TableCell>
                <TableCell>Крымова А.А.</TableCell>
                <TableCell>Ж</TableCell>
                <TableCell>19</TableCell>
                <TableCell>Б13-401</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст401.6</TableCell>
                <TableCell>Ризина Г.Н.</TableCell>
                <TableCell>Ж</TableCell>
                <TableCell>20</TableCell>
                <TableCell>Б13-401</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст402.1</TableCell>
                <TableCell>Стоянов А.Т.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>20</TableCell>
                <TableCell>Б14-402</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст501.1</TableCell>
                <TableCell>Серж С.Ю.</TableCell>
                <TableCell>Ж</TableCell>
                <TableCell>20</TableCell>
                <TableCell>Б14-501</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст501.2</TableCell>
                <TableCell>Котова В.И.</TableCell>
                <TableCell>Ж</TableCell>
                <TableCell>20</TableCell>
                <TableCell>Б14-501</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст502.1</TableCell>
                <TableCell>Дикий М.Т.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>19</TableCell>
                <TableCell>Б13-502</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст502.2</TableCell>
                <TableCell>Озерова Т.И.</TableCell>
                <TableCell>Ж</TableCell>
                <TableCell>20</TableCell>
                <TableCell>Б13-502</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст505.1</TableCell>
                <TableCell>Иванова В.И.</TableCell>
                <TableCell>Ж</TableCell>
                <TableCell>20</TableCell>
                <TableCell>Б14-505</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст505.2</TableCell>
                <TableCell>Левина А.Ю.</TableCell>
                <TableCell>Ж</TableCell>
                <TableCell>21</TableCell>
                <TableCell>Б14-505</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст505.3</TableCell>
                <TableCell>Полякова С.Т.</TableCell>
                <TableCell>Ж</TableCell>
                <TableCell>22</TableCell>
                <TableCell>Б14-505</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст505.4</TableCell>
                <TableCell>Полин С.Т.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>22</TableCell>
                <TableCell>Б14-505</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст505.5</TableCell>
                <TableCell>Силин С.Т.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>22</TableCell>
                <TableCell>Б14-505</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст505.6</TableCell>
                <TableCell>Смолин С.Т.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>22</TableCell>
                <TableCell>Б14-505</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст701.1</TableCell>
                <TableCell>Володин К.П.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>22</TableCell>
                <TableCell>Б14-701</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст701.2</TableCell>
                <TableCell>Серов П.П.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>21</TableCell>
                <TableCell>Б14-701</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст701.3</TableCell>
                <TableCell>Акишин М.Б.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>21</TableCell>
                <TableCell>Б14-701</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст701.4</TableCell>
                <TableCell>Яшина Е.И.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>22</TableCell>
                <TableCell>Б14-701</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст701.8</TableCell>
                <TableCell>Яшин Е.И.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>22</TableCell>
                <TableCell>Б14-701</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст901.1</TableCell>
                <TableCell>Рогозина Г.Н.</TableCell>
                <TableCell>Ж</TableCell>
                <TableCell>20</TableCell>
                <TableCell>Б14-901</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст901.2</TableCell>
                <TableCell>Крымов Н.А.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>19</TableCell>
                <TableCell>Б14-901</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст901.3</TableCell>
                <TableCell>Иванова В.И.</TableCell>
                <TableCell>Ж</TableCell>
                <TableCell>21</TableCell>
                <TableCell>Б14-901</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст901.4</TableCell>
                <TableCell>Громов Н.А.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>19</TableCell>
                <TableCell></TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст902.4</TableCell>
                <TableCell>Трикова Л.В.</TableCell>
                <TableCell>Ж</TableCell>
                <TableCell>20</TableCell>
                <TableCell></TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст903.1</TableCell>
                <TableCell>Погудин О.В.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>20</TableCell>
                <TableCell>Б15-903</TableCell>
              </TableRow>
              <TableRow>
                <TableCell>ст903.2</TableCell>
                <TableCell>Погожин Д.И.</TableCell>
                <TableCell>М</TableCell>
                <TableCell>21</TableCell>
                <TableCell>Б15-903</TableCell>
              </TableRow>
            </TableBody>
          </Table>
        ) : (
          <></>
        )}
      </div>
    </div>
  );
}
