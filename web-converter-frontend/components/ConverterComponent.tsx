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
import {
  Drawer,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerFooter,
  DrawerHeader,
  DrawerTitle,
  DrawerTrigger,
} from "@/components/ui/drawer";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { ScrollArea } from "@/components/ui/scroll-area";
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
import {
  createView,
  executeSQL,
  getAllColumns,
  getAllTables,
} from "@/services/genericData";
import {
  ConvertQuery,
  Query,
  QueryName,
  SQLQuery,
  TableName,
} from "@/types/Query";
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
import { useHotkeys } from "react-hotkeys-hook";
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
    convertQuery,
  } = require(`@/services/${converterType}Data`);

  const [toggleResultTable, setToggleResultTable] = useState(false);
  const [selectedQuery, setSelectedQuery] = useState(0);
  const [selectedTables, setSelectedTables] = useState<string[]>([""]);
  const [applyQuery, setApplyQuery] = useState(false);
  const [deleteQueryDialogOpen, setDeleteQueryDialogOpen] = useState(false);
  const { toast } = useToast();

  const {
    register,
    handleSubmit,
    reset,
    setValue,
    getValues,
    setError,
    clearErrors,
    watch,
    formState: { errors },
  } = useForm<Query>();
  const sqlQueryForm = useForm<SQLQuery>();

  const watchTableVariables = watch("table_variables");

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
  const getAllColumnsData = useQuery(
    ["getAllColumns", selectedTables],
    () => getAllColumns({ table_names: selectedTables }),
    { enabled: false }
  );

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
  const convertQueryMutation = useMutation({
    mutationFn: (data: ConvertQuery) => convertQuery(data),
    onSuccess: (data: string) => {
      clearErrors("query_body");
      sqlQueryForm.setValue("sql_query", data);
      toast({
        title: "Успех",
        description: "SQL запрос успешно конвертирован!",
      });
    },
    onError() {
      setError("query_body", {
        type: "generate",
        message: "conversion error",
      });
    },
  });
  const executeSQLMutation = useMutation(executeSQL, {
    onSuccess: () => {
      sqlQueryForm.clearErrors("sql_query");
      setToggleResultTable(true);
    },
    onError(error) {
      console.log(error);
      sqlQueryForm.setError("sql_query", {
        type: "execute",
        message: "Execution error",
      });
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
  const onConvertQuerySubmit: SubmitHandler<Query> = (data) => {
    convertQueryMutation.mutate({
      table_variables: data.table_variables,
      target_list: data.target_list,
      query_body: data.query_body,
    });
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

  useEffect(() => {
    if (watchTableVariables) {
      const tables = watchTableVariables
        .replaceAll(", ", ",")
        .split(",")
        .map((row) => row.split(" ")[0]);

      setSelectedTables(Array.from(new Set(tables)));
    } else {
      setSelectedTables([""]);
    }

    console.log(selectedTables);
  }, [watchTableVariables]);

  useEffect(() => {
    if (selectedTables.length !== 0) {
      getAllColumnsData.refetch();
    }
  }, [selectedTables]);

  useEffect(() => {
    console.log(getAllColumnsData.data);
  }, [getAllColumnsData.data]);

  const letterGenerator = generateLetter();

  const onApplyButtonClick = () => {
    selectedQuery === 0
      ? toast({
          title: "Ошибка",
          description: "Для применения запроса необходимо его выбрать!",
        })
      : Object.entries(getQueryByIdData.data).forEach(([name, value]: any) =>
          setValue(name, value)
        );
  };
  const onApplyCancelButtonClick = () => {
    setSelectedQuery(0);
    reset();
  };
  const onApplyClearFieldsButtonClick = () => {
    reset();
  };
  const onSaveButtonClick = () => {
    setApplyQuery(false);
    handleSubmit(onSaveQuerySubmit)();
  };
  const onEditButtonClick = () => {
    setApplyQuery(false);
    handleSubmit(onEditQuerySubmit)();
  };
  const onDeleteButtonClick = () => {
    setDeleteQueryDialogOpen(true);
  };
  const onGenerateSQLButtonClick = () => {
    setApplyQuery(true);
    handleSubmit(onConvertQuerySubmit)();
  };
  const onRefreshSQLButtonClick = () => {
    sqlQueryForm.handleSubmit(onExecuteSQLSubmit)();
  };
  const onCloseTableButtonClick = () => {
    setToggleResultTable(false);
  };
  const onExecuteSQLButtonClick = () => {
    sqlQueryForm.handleSubmit(onExecuteSQLSubmit)();
  };
  const onCreateViewButtonClick = () => {
    sqlQueryForm.handleSubmit(onCreateViewSubmit)();
  };

  const hotkeysOptions = {
    enableOnFormTags: true,
  };
  useHotkeys("ctrl+alt+a", onApplyButtonClick, hotkeysOptions);
  useHotkeys("ctrl+alt+c", onApplyClearFieldsButtonClick, hotkeysOptions);
  useHotkeys("ctrl+alt+s", onSaveButtonClick, hotkeysOptions);
  useHotkeys("ctrl+alt+e", onEditButtonClick, hotkeysOptions);
  useHotkeys("ctrl+alt+d", onDeleteButtonClick, hotkeysOptions);
  useHotkeys("ctrl+alt+g", onGenerateSQLButtonClick, hotkeysOptions);
  useHotkeys("ctrl+alt+r", onRefreshSQLButtonClick, hotkeysOptions);
  useHotkeys("ctrl+alt+t", onCloseTableButtonClick, hotkeysOptions);
  useHotkeys("ctrl+alt+x", onExecuteSQLButtonClick, hotkeysOptions);
  useHotkeys("ctrl+alt+v", onCreateViewButtonClick, hotkeysOptions);

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
                      <ScrollArea className="h-80 px-4 py-1">
                        <div className="flex flex-col gap-1.5">
                          {getAllTablesData.data.map((row: TableName) => (
                            <Button
                              key={row.table_name}
                              variant="outline"
                              onClick={() =>
                                getValues("table_variables") === ""
                                  ? setValue(
                                      "table_variables",
                                      `${
                                        row.table_name
                                      } AS ${letterGenerator()}`
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
                      </ScrollArea>
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
                  {...register("table_variables", {
                    validate: (value) => {
                      if (!applyQuery) return true;
                      return value !== "";
                    },
                  })}
                />
                {errors.table_variables && (
                  <div className="text-center text-sm text-red-700">
                    Это поле обязательно!
                  </div>
                )}
              </div>
            </div>
            <div className="flex flex-col gap-1.5">
              <div className="flex flex-row justify-between">
                <Label className="self-end" htmlFor="target-list">
                  Целевой список:
                </Label>
                {!!getAllColumnsData.data &&
                  !getAllColumnsData.data.hasOwnProperty("") && (
                    <Popover>
                      <PopoverTrigger asChild>
                        <Button variant="outline" title="Добавить переменную">
                          <Plus />
                        </Button>
                      </PopoverTrigger>
                      <PopoverContent className="w-80">
                        <ScrollArea className="h-80 px-4 py-1">
                          <div className="flex flex-col gap-1.5">
                            {watchTableVariables
                              ?.replaceAll(", ", ",")
                              .split(",")
                              .map((row) => row.split(" "))
                              .map((name) =>
                                getAllColumnsData.data[name[0]]?.map(
                                  (column: string) => (
                                    <Button
                                      key={`${name[0]}${name[2]}${column}`}
                                      variant="outline"
                                      onClick={() =>
                                        getValues("target_list") === ""
                                          ? setValue(
                                              "target_list",
                                              `${name[2]}.${column}`
                                            )
                                          : setValue(
                                              "target_list",
                                              `${getValues("target_list")}, ${
                                                name[2]
                                              }.${column}`
                                            )
                                      }
                                    >
                                      <Plus className="mr-1" />
                                      {`${name[2]}.${column}`}
                                    </Button>
                                  )
                                )
                              )}
                          </div>
                        </ScrollArea>
                      </PopoverContent>
                    </Popover>
                  )}
              </div>
              <Input
                id="target-list"
                type="text"
                {...register("target_list", {
                  validate: (value) => {
                    if (!applyQuery) return true;
                    return value !== "";
                  },
                })}
              />
              {errors.target_list && (
                <div className="text-center text-sm text-red-700">
                  Это поле обязательно!
                </div>
              )}
            </div>
            <div className="flex grow flex-col gap-5 lg:flex-row">
              <div className="flex w-full flex-col gap-1.5">
                <div className="flex flex-row justify-between">
                  <Label className="self-end" htmlFor="input-query">
                    Выражение:
                  </Label>
                  {!!getAllColumnsData.data &&
                    !getAllColumnsData.data.hasOwnProperty("") && (
                      <Popover>
                        <PopoverTrigger asChild>
                          <Button variant="outline" title="Добавить переменную">
                            <Plus />
                          </Button>
                        </PopoverTrigger>
                        <PopoverContent className="w-80">
                          <ScrollArea className="h-80 px-4 py-1">
                            <div className="flex flex-col gap-1.5">
                              {watchTableVariables
                                ?.replaceAll(", ", ",")
                                .split(",")
                                .map((row) => row.split(" "))
                                .map((name) =>
                                  getAllColumnsData.data[name[0]]?.map(
                                    (column: string) => (
                                      <Button
                                        key={`${name[0]}${name[2]}${column}`}
                                        variant="outline"
                                        onClick={() =>
                                          getValues("query_body") === ""
                                            ? setValue(
                                                "query_body",
                                                `${name[2]}.${column}`
                                              )
                                            : setValue(
                                                "query_body",
                                                `${getValues("query_body")}${
                                                  name[2]
                                                }.${column}`
                                              )
                                        }
                                      >
                                        <Plus className="mr-1" />
                                        {`${name[2]}.${column}`}
                                      </Button>
                                    )
                                  )
                                )}
                            </div>
                          </ScrollArea>
                        </PopoverContent>
                      </Popover>
                    )}
                </div>
                <Textarea
                  className="grow resize-none"
                  id="input-query"
                  {...register("query_body", {
                    validate: (value) => {
                      if (!applyQuery) return true;
                      return value !== "";
                    },
                  })}
                />
                {errors.query_body?.type === "validate" && (
                  <div className="text-center text-sm text-red-700">
                    Это поле обязательно!
                  </div>
                )}
                {errors.query_body?.type === "generate" && (
                  <div className="text-center text-sm text-red-700">
                    Невозможно преобразовать выражение. Выражение содержит
                    ошибки!
                  </div>
                )}
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
                {sqlQueryForm.formState.errors.sql_query?.type ===
                  "required" && (
                  <div className="text-center text-sm text-red-700">
                    Это поле обязательно!
                  </div>
                )}
                {sqlQueryForm.formState.errors.sql_query?.type ===
                  "execute" && (
                  <div className="text-center text-sm text-red-700">
                    Неверный SQL-запрос!
                  </div>
                )}
              </div>
            </div>
          </div>
        </form>
        <div className="flex flex-col gap-3">
          <div className="flex flex-col gap-1.5">
            {selectedQuery === 0 ? (
              <Button className="flex grow" onClick={onApplyButtonClick}>
                <Check className="mr-2" /> Принять запрос
              </Button>
            ) : (
              <>
                <Button onClick={onApplyButtonClick}>
                  <Check className="mr-2" /> Принять запрос
                </Button>
                <Button variant="outline" onClick={onApplyCancelButtonClick}>
                  <X className="mr-2" /> Отменить выбор
                </Button>
                <Button
                  variant="outline"
                  onClick={onApplyClearFieldsButtonClick}
                >
                  <Trash2 className="mr-2" /> Очистить поля
                </Button>
              </>
            )}
          </div>
          <Button variant="secondary" onClick={onSaveButtonClick}>
            <Save className="mr-2" />
            {selectedQuery === 0
              ? "Сохранить запрос"
              : "Сохранить копию запроса"}
          </Button>
          <Button variant="secondary" onClick={onEditButtonClick}>
            <Pen className="mr-2" /> Изменить запрос
          </Button>
          <Dialog
            open={deleteQueryDialogOpen}
            onOpenChange={setDeleteQueryDialogOpen}
          >
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
          <Button onClick={onGenerateSQLButtonClick}>
            <Plus className="mr-2" /> Генерировать SQL
          </Button>
          <div className="flex flex-row gap-1.5">
            {toggleResultTable ? (
              <>
                <Button
                  className="flex grow"
                  variant="secondary"
                  onClick={onRefreshSQLButtonClick}
                >
                  <RefreshCcw className="mr-2" /> Обновить
                </Button>
                <Button variant="destructive" onClick={onCloseTableButtonClick}>
                  <X />
                </Button>
              </>
            ) : (
              <Button className="flex grow" onClick={onExecuteSQLButtonClick}>
                <SendHorizontal className="mr-2" /> Выполнить SQL
              </Button>
            )}
          </div>
          <Separator />
          <Button variant="secondary" onClick={onCreateViewButtonClick}>
            <Save className="mr-2" /> Создать View
          </Button>
          <Separator />
          <Drawer>
            <DrawerTrigger asChild>
              <Button variant="secondary">
                <Save className="mr-2" /> Список сочетаний клавиш
              </Button>
            </DrawerTrigger>
            <DrawerContent>
              <DrawerHeader>
                <DrawerTitle className="text-center text-lg">
                  Сочетания клавиш
                </DrawerTitle>
                <DrawerDescription>
                  <div className="grid grid-cols-2 justify-items-center gap-x-8">
                    <p className="justify-self-end text-lg font-bold text-slate-950">
                      CTRL+ALT+A
                    </p>
                    <p className="justify-self-start text-lg">Принять запрос</p>

                    <p className="justify-self-end text-lg font-bold text-slate-950">
                      CTRL+ALT+C
                    </p>
                    <p className="justify-self-start text-lg">Очистить поля</p>

                    <p className="justify-self-end text-lg font-bold text-slate-950">
                      CTRL+ALT+S
                    </p>
                    <p className="justify-self-start text-lg">
                      Сохранить запрос
                    </p>

                    <p className="justify-self-end text-lg font-bold text-slate-950">
                      CTRL+ALT+E
                    </p>
                    <p className="justify-self-start text-lg">
                      Изменить запрос
                    </p>

                    <p className="justify-self-end text-lg font-bold text-slate-950">
                      CTRL+ALT+D
                    </p>
                    <p className="justify-self-start text-lg">Удалить запрос</p>

                    <p className="justify-self-end text-lg font-bold text-slate-950">
                      CTRL+ALT+G
                    </p>
                    <p className="justify-self-start text-lg">
                      Генерировать SQL
                    </p>

                    <p className="justify-self-end text-lg font-bold text-slate-950">
                      CTRL+ALT+X
                    </p>
                    <p className="justify-self-start text-lg">Выполнить SQL</p>

                    <p className="justify-self-end text-lg font-bold text-slate-950">
                      CTRL+ALT+R
                    </p>
                    <p className="justify-self-start text-lg">
                      Обновить таблицу вывода
                    </p>

                    <p className="justify-self-end text-lg font-bold text-slate-950">
                      CTRL+ALT+T
                    </p>
                    <p className="justify-self-start text-lg">
                      Закрыть таблицу вывода
                    </p>

                    <p className="justify-self-end text-lg font-bold text-slate-950">
                      CTRL+ALT+V
                    </p>
                    <p className="justify-self-start text-lg">Создать View</p>
                  </div>
                </DrawerDescription>
              </DrawerHeader>
              <DrawerFooter>
                <DrawerClose>
                  <Button variant="outline">Закрыть</Button>
                </DrawerClose>
              </DrawerFooter>
            </DrawerContent>
          </Drawer>
        </div>
      </div>
      <div className="flex flex-row justify-center" id="result-table">
        {toggleResultTable &&
          (!!executeSQLMutation.data ? (
            !executeSQLMutation.data.length ? (
              <p className="text-lg font-bold lg:text-2xl">
                Результат на SQL-запрос пуст!
              </p>
            ) : (
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
            )
          ) : (
            <p>Загрузка</p>
          ))}
      </div>
    </div>
  );
}
