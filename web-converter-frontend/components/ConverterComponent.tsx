"use client";

import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { Separator } from "@/components/ui/separator";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Textarea } from "@/components/ui/textarea";
import { useToast } from "@/components/ui/use-toast";
import { createView, executeSQL, getAllTables } from "@/services/genericData";
import { Query, QueryName, SQLQuery, TableName } from "@/types/Query";
import { emptyQueryStringsToNull, generateLetter } from "@/utils/tools";
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
import { useEffect, useState } from "react";
import { SubmitHandler, useForm } from "react-hook-form";
import { useMutation, useQuery } from "react-query";

export default function ConverterComponent({
  converterType,
}: {
  converterType: string;
}) {
  const {
    addQuery,
    deleteQuery,
    editQuery,
    getAllQueriesNames,
    getQueryById,
  } = require(`@/services/${converterType}Data`);

  const [toggleResultTable, setToggleResultTable] = useState(false);
  const [selectedQuery, setSelectedQuery] = useState(0);
  const { toast } = useToast();

  const {
    register,
    handleSubmit,
    reset,
    setValue,
    getValues,
    formState: { errors },
  } = useForm<Query>();
  const sqlQueryForm = useForm<SQLQuery>();

  const getAllQueriesNamesData = useQuery<QueryName[]>(
    "getAllQueriesNames",
    getAllQueriesNames
  );
  const getQueryByIdData = useQuery(
    ["getQueryById", selectedQuery],
    () => getQueryById(selectedQuery),
    {
      enabled: false,
    }
  );
  const deleteQueryData = useQuery(
    ["deleteQuery", selectedQuery],
    () => deleteQuery(selectedQuery),
    {
      enabled: false,
    }
  );
  const getAllTablesData = useQuery("getAllTables", getAllTables);

  const addQueryMutation = useMutation({
    mutationFn: (data: Query) => addQuery(data),
    onSuccess: (data: { id: number }) => {
      getAllQueriesNamesData.refetch().then(() => {
        setSelectedQuery(data.id);
        toast({
          title: "Успех",
          description: "Запрос успешно сохранен!",
        });
      });
    },
  });
  const editQueryMutation = useMutation({
    mutationFn: (data: { queryId: number; query: Query }) => editQuery(data),
    onSuccess: () => {
      getAllQueriesNamesData.refetch();
      toast({
        title: "Успех",
        description: "Запрос успешно изменен!",
      });
    },
  });
  const executeSQLMutation = useMutation(executeSQL, {
    onSuccess: () => {
      setToggleResultTable(true);
    },
  });
  const createViewMutation = useMutation(createView, {
    onSuccess: (data) => {
      toast({
        title: "Успех",
        description: `View запроса с названием ${data} успешно создан!`,
      });
    },
  });

  const onSaveQuerySubmit: SubmitHandler<Query> = (data) => {
    emptyQueryStringsToNull(data);
    addQueryMutation.mutate(data);
  };
  const onEditQuerySubmit: SubmitHandler<Query> = (data) => {
    if (selectedQuery === 0) {
      toast({
        title: "Ошибка",
        description: "Для изменения запроса необходимо его выбрать!",
      });
    } else {
      emptyQueryStringsToNull(data);
      editQueryMutation.mutate({ queryId: selectedQuery, query: data });
    }
  };
  const onExecuteSQLSubmit: SubmitHandler<SQLQuery> = (data) => {
    executeSQLMutation.mutate({
      sql_query: data.sql_query,
    });
  };
  const onCreateViewSubmit: SubmitHandler<SQLQuery> = (data) => {
    const getQueryFormData = handleSubmit((data) => {
      return data;
    });
    getQueryFormData().then(() => {
      const queryFormData = getValues(["query_id", "query_group", "last_name"]);
      if (!queryFormData.includes("")) {
        createViewMutation.mutate({
          title: `${queryFormData[0]}_${queryFormData[1]}_${queryFormData[2]}`,
          sql_query: data.sql_query,
        });
      }
    });
  };

  useEffect(() => {
    if (deleteQueryData.isSuccess) {
      getAllQueriesNamesData.refetch();
      setSelectedQuery(0);
      reset();
      toast({
        title: "Успех",
        description: "Запрос успешно удален!",
      });
    }
  }, [deleteQueryData.isSuccess]);

  useEffect(() => {
    getQueryByIdData.refetch();
  }, [selectedQuery]);

  const letterGenerator = generateLetter();

  return (
    <div className="flex flex-col gap-5">
      <div className="flex flex-col gap-5 lg:flex-row">
        <form className="flex flex-auto">
          <div className="flex flex-auto flex-col gap-5">
            <div className="flex flex-col items-center gap-1.5 lg:flex-row">
              <Label htmlFor="group">Группа:</Label>
              <Input
                className={errors.query_group ? "border-red-700" : ""}
                id="group"
                type="text"
                {...register("query_group", { required: true, minLength: 1 })}
              />
              {errors.query_group && (
                <div className="text-center text-sm text-red-700">
                  Это поле обязательно!
                </div>
              )}

              <Label htmlFor="last-name">Фамилия:</Label>
              <Input
                className={errors.last_name ? "border-red-700" : ""}
                id="last-name"
                type="text"
                {...register("last_name", { required: true, minLength: 1 })}
              />
              {errors.last_name && (
                <div className="text-center text-sm text-red-700">
                  Это поле обязательно!
                </div>
              )}

              <Label htmlFor="identification-number">Номер запроса:</Label>
              <Input
                className={errors.query_id ? "border-red-700" : ""}
                id="identification-number"
                type="text"
                {...register("query_id", { required: true, minLength: 1 })}
              />
              {errors.query_id && (
                <div className="text-center text-sm text-red-700">
                  Это поле обязательно!
                </div>
              )}

              {!!getAllQueriesNamesData.data ? (
                <select
                  value={selectedQuery.toString()}
                  onChange={(e) => setSelectedQuery(parseInt(e.target.value))}
                  className="flex h-10 w-full items-center justify-between rounded-md border px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50 [&>span]:line-clamp-1"
                >
                  <option value="0" disabled hidden>
                    Запрос
                  </option>
                  {getAllQueriesNamesData.data.map((row: QueryName) => (
                    <option key={row.id} value={row.id.toString()}>
                      {`${row.query_id}_${row.query_group}_${row.last_name}`}
                    </option>
                  ))}
                </select>
              ) : (
                <p>Загрузка...</p>
              )}
            </div>
            <div className="grid gap-x-5 gap-y-1.5 lg:grid-cols-2">
              <div className="order-1 flex items-end lg:order-none">
                <Label htmlFor="description">Описание запроса:</Label>
              </div>
              <div className="order-3 flex items-end justify-between lg:order-none">
                <Label htmlFor="variable-types">Типы переменных:</Label>
                {!!getAllTablesData.data ? (
                  <Popover>
                    <PopoverTrigger asChild>
                      <Button variant="outline" title="Добавить переменную">
                        <Plus />
                      </Button>
                    </PopoverTrigger>
                    <PopoverContent className="w-80">
                      <div className="flex flex-col gap-1.5">
                        {getAllTablesData.data.map((row: TableName) => (
                          <Button
                            key={row.table_name}
                            variant="outline"
                            onClick={() =>
                              getValues("table_variables") === ""
                                ? setValue(
                                    "table_variables",
                                    `${row.table_name} AS ${letterGenerator()}`
                                  )
                                : setValue(
                                    "table_variables",
                                    `${getValues("table_variables")}, ${
                                      row.table_name
                                    } AS ${letterGenerator()}`
                                  )
                            }
                          >
                            <Plus className="mr-1" /> {row.table_name}
                          </Button>
                        ))}
                      </div>
                    </PopoverContent>
                  </Popover>
                ) : (
                  <p>Загрузка...</p>
                )}
              </div>
              <div className="order-2 lg:order-none">
                <Textarea
                  className="resize-none"
                  id="description"
                  {...register("description")}
                />
              </div>
              <div className="order-4 lg:order-none">
                <Textarea
                  className="resize-none"
                  id="variable-types"
                  {...register("table_variables")}
                />
              </div>
            </div>
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="target-list">Целевой список:</Label>
              <Input
                id="target-list"
                type="text"
                {...register("target_list")}
              />
            </div>
            <div className="flex grow flex-col gap-5 lg:flex-row">
              <div className="flex w-full flex-col gap-1.5">
                <Label htmlFor="input-query">Выражение:</Label>
                <Textarea
                  className="grow resize-none"
                  id="input-query"
                  {...register("query_body")}
                />
              </div>
              <div className="flex w-full flex-col gap-1.5">
                <Label htmlFor="output-query">SQL-выражение:</Label>
                <Textarea
                  className="grow resize-none"
                  id="output-query"
                  {...sqlQueryForm.register("sql_query", {
                    required: true,
                    minLength: 1,
                  })}
                />
                {sqlQueryForm.formState.errors.sql_query && (
                  <div className="text-center text-sm text-red-700">
                    Это поле обязательно!
                  </div>
                )}
              </div>
            </div>
          </div>
        </form>
        <div className="flex flex-col gap-3">
          <div className="flex flex-col gap-1.5">
            {selectedQuery === 0 ? (
              <Button
                className="flex grow"
                onClick={() => {
                  selectedQuery === 0
                    ? toast({
                        title: "Ошибка",
                        description:
                          "Для применения запроса необходимо его выбрать!",
                      })
                    : Object.entries(getQueryByIdData.data).forEach(
                        ([name, value]: any) => setValue(name, value)
                      );
                }}
              >
                <Check className="mr-2" /> Принять запрос
              </Button>
            ) : (
              <>
                <Button
                  onClick={() => {
                    selectedQuery === 0
                      ? toast({
                          title: "Ошибка",
                          description:
                            "Для применения запроса необходимо его выбрать!",
                        })
                      : Object.entries(getQueryByIdData.data).forEach(
                          ([name, value]: any) => setValue(name, value)
                        );
                  }}
                >
                  <Check className="mr-2" /> Принять запрос
                </Button>
                <Button
                  variant="outline"
                  onClick={() => {
                    setSelectedQuery(0);
                    reset();
                  }}
                >
                  <X className="mr-2" /> Отменить выбор
                </Button>
                <Button
                  variant="outline"
                  onClick={() => {
                    reset();
                  }}
                >
                  <Trash2 className="mr-2" /> Очистить поля
                </Button>
              </>
            )}
          </div>
          <Button variant="secondary" onClick={handleSubmit(onSaveQuerySubmit)}>
            <Save className="mr-2" />
            {selectedQuery === 0
              ? "Сохранить запрос"
              : "Сохранить копию запроса"}
          </Button>
          <Button variant="secondary" onClick={handleSubmit(onEditQuerySubmit)}>
            <Pen className="mr-2" /> Изменить запрос
          </Button>
          <Dialog>
            <DialogTrigger asChild>
              <Button variant="destructive">
                <Trash2 className="mr-2" /> Удалить запрос
              </Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-md">
              <DialogHeader>
                <DialogTitle>
                  Вы уверены, что хотите удалить этот запрос?
                </DialogTitle>
              </DialogHeader>
              <DialogFooter className="sm:justify-center">
                <DialogClose asChild>
                  <Button type="button" variant="secondary">
                    Нет
                  </Button>
                </DialogClose>
                <DialogClose asChild>
                  <Button
                    variant="destructive"
                    onClick={() => {
                      selectedQuery === 0
                        ? toast({
                            title: "Ошибка",
                            description:
                              "Для удаления запроса необходимо его выбрать!",
                          })
                        : deleteQueryData.refetch();
                    }}
                  >
                    Да
                  </Button>
                </DialogClose>
              </DialogFooter>
            </DialogContent>
          </Dialog>
          <Separator />
          <Button>
            <Plus className="mr-2" /> Генерировать SQL
          </Button>
          <div className="flex flex-row gap-1.5">
            {toggleResultTable ? (
              <>
                <Button
                  className="flex grow"
                  variant="secondary"
                  onClick={sqlQueryForm.handleSubmit(onExecuteSQLSubmit)}
                >
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
                onClick={sqlQueryForm.handleSubmit(onExecuteSQLSubmit)}
              >
                <SendHorizontal className="mr-2" /> Выполнить SQL
              </Button>
            )}
          </div>
          <Separator />
          <Button
            variant="secondary"
            onClick={sqlQueryForm.handleSubmit(onCreateViewSubmit)}
          >
            <Save className="mr-2" /> Создать View
          </Button>
        </div>
      </div>
      <div className="flex flex-row" id="result-table">
        {toggleResultTable &&
          (!!executeSQLMutation.data ? (
            <Table className="border">
              <TableHeader>
                <TableRow>
                  {Object.keys(executeSQLMutation.data[0]).map(
                    (key: string) => (
                      <TableHead key={key}>{key}</TableHead>
                    )
                  )}
                </TableRow>
              </TableHeader>
              <TableBody>
                {executeSQLMutation.data.map((row: any) => (
                  <TableRow key={row.id}>
                    {Object.values(row).map((value) => (
                      <TableCell key={value as any}>{value as any}</TableCell>
                    ))}
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          ) : (
            <p>Загрузка</p>
          ))}
      </div>
    </div>
  );
}
