typedef GetProperty<FieldT, AggregateT> = FieldT? Function(AggregateT obj);
typedef ResolveProperty<AggregateT> = FieldT? Function<FieldT>(FieldT? Function(AggregateT obj));

ResolveProperty<AggregateT> makeResolver<AggregateT>(AggregateT? first, AggregateT? second, [ AggregateT? third ]) {
  if (first == null && second == null) 
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(third!);
  else if (first == null && third == null) 
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(second!);
  else if (second == null && third == null) 
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(first!);
  else if (third == null)
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(first!) ?? getProperty(second!);
  else if (second == null)
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(first!) ?? getProperty(third);
  else if (first == null) 
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(second) ?? getProperty(third);
  else 
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(first) ?? getProperty(second) ?? getProperty(third);
}

ResolveProperty<AggregateT> makeResolver4<AggregateT>(AggregateT? first, AggregateT? second, AggregateT? third, AggregateT fourth) {
  if (first == null && second == null && third == null)
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(fourth);
  else if (first == null && second == null)
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(third!) ?? getProperty(fourth);
  else if (second == null && third == null) 
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(first!) ?? getProperty(fourth);
  else if (first == null && third == null) 
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(second!) ?? getProperty(fourth);
  else if (first == null)
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(second!) ?? getProperty(third!) ?? getProperty(fourth);
  else if (second == null)
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(first) ?? getProperty(third!) ?? getProperty(fourth);
  else if (third == null)
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(first) ?? getProperty(second) ?? getProperty(fourth);
  else
    return <FieldT>(GetProperty<FieldT, AggregateT> getProperty) => getProperty(first) ?? getProperty(second) ?? getProperty(third) ?? getProperty(fourth);
}